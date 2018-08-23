# AbsintheAuth

![CircleCI](https://img.shields.io/circleci/project/github/expert360/absinthe_auth.svg)
![Codecov](https://img.shields.io/codecov/c/github/expert360/absinthe_auth.svg)
![Hex.pm](https://img.shields.io/hexpm/dt/absinthe_auth.svg)
![Hex.pm](https://img.shields.io/hexpm/v/absinthe_auth.svg)
[![Inline docs](http://inch-ci.org/github/expert360/absinthe_auth.svg)](http://inch-ci.org/github/expert360/absinthe_auth)

(Opinionated) Authorisation framework for [Absinthe](https://hexdocs.pm/absinthe/).

## Authorisation in the Graph Layer

There are many approaches to doing authorisation in GraphQL. This approach is to do
it entirely within the GraphQL layer. This means that backing services don't need to know
anything about what rules need to be applied for a given query.

It also means that:

* authorisation policy is kept within the schema so it's easy to reason about
* backing services can be simplified
* authorisation can be applied to fields _before_ resolution (maybe avoiding hitting the backing service at all)
* different API layers (Graph, REST or anything else) can implement their own permission logic and keep the same backing services

## Usage

`AbsintheAuth` defines a macro `policy` that can be used inside `Absinthe.Schema` definitions.
It basically just injects a middleware.

```elixir
defmodule Movies.Schema do
  use Absinthe.Schema
  use AbsintheAuth

  query do
    field :movie, :movie do
      policy MyPolicy, :check
    end
  end
end
```

`policy/3` takes a module and the name of a function to call on that module
as well as a list of optional options to pass to the policy (as a list).

### Defining Policies

A policy is super generic. It's basically just a middleware but contains some
additional logic to ensure requests are denied if no policy matches as well
as simplifying how queries and mutations are handled.

A policy can be whatever you like. It's up to you. A really simple policy would
be to just deny all access to a field:

```elixir
defmodule DenyAllPolicy do
  use AbsintheAuth.Policy

  def check(resolution, _opts) do
    deny!(resolution)
  end
  def check(resolution, _parent, _opts) do
    deny!(resolution)
  end
end
```

Note that there are two versions of check - a 2 arity and a 3 arity function.
The 3 arity function will be called when there is a parent record that is not the query or
mutation root. Your policy should define both a 2 and a 3 arity version of any functions.

See `AbsintheAuth.Policy` for more details and examples.

## Policy Semantics

Multiple policies can be defined on any field. If no policy is added
then the normal resolution process will occur (including any middlewares you have).
However, when you add multiple policies, at least *one* of them will need to explicitly
allow the request or else the request will be denied.

```elixir
object :movie do
  field :id, non_null(:id)
  field :title, :string
  field :budget do
    policy Studio, :allow
    policy Permission, :check
  end
end
```

Semantically, you could read this as saying that if the viewer of the request works for
a studio then allow them to see the budget field. If not, but the user has explicitly been
given permission to the budget field on this record then allow them to see it. Otherwise,
the request will be denied.

Policies *must* always return the resolution - either denied, allowed or deferred. See
`AbsintheAuth.Policy.deny!/1`, `AbsintheAuth.Policy.allow!/1` and `AbsintheAuth.Policy.defer/1`
for details.

### Using the Absinthe Context

One approach (although there are many others) to verifying permissions within a policy
is to use information available in the context. The most obvious idea is to check against
the currently logged in user (`current_user` or `viewer` depending on your preference.

Suppose you have the `viewer` set in the context (see [Absinthe](https://hexdocs.pm/absinthe/context-and-authentication.html#content)
for more information on this).

```
%{
  context: %{
    viewer: %{id: 1}
  }
}
```

We can access this information in the policy.

A simple example:

```elixir
defmodule OwnerPolicy do
  use AbsintheAuth.Policy
  
  def allow(resolution, _) do
    # Can't be an owner of the root
    deny!(resolution)
  end
  def allow(%{context: %{viewer: %{id: id}}}, %{owner_id: id} = rec, _) do
    # Allow when I'm the owner of the target record
    allow!(resolution)
  end
end
```
    
Or, let's say we want to allow if the user is an admin:

```elixir
defmodule AdminPolicy do
  use AbsintheAuth.Policy

  def allow(%{context: %{viewer: %{id: id}}}, _) do
    with {:ok, user} <- Users.find_user(id),
         true <- Users.is_admin?(user) do

      allow!(resolution)
    else
      _ ->
        deny!(resolution)
    end
  end
end
```

Of course, this second example might not be very efficient because we could end up calling
it many times for a single query. If either of the functions in the `Users` module
need to hit the database this could be problematic indeed!

### Prefetching Permissions or Roles

An alternative is to load all the info required to verify access into the context at the start of each request.
While this could require a multi-row database query it will only be executed once per query thus avoiding
any N+1 query type issues.

```
%{
  context: %{
    permissions: [
      "view",
      "create_project"
    ]
  }
}
```

A "permission" policy:

```elixir
defmodule PermissionPolicy do
  use AbsintheAuth.Policy

  def view(%{context: %{permissions: permissions}}, _) do
    if "view" in permissions do
      allow!(resolution)
    else
      deny!(resolution)
    end
  end
end
```

### Denied Responses

A key principle of GraphQL is that responses should maintain the shape of a request. Therefore,
when a field is denied it should still be returned in the response but with it's value set to null.

Additionally, an error message can be included.

Using `AbsintheAuth.Policy.deny!/1` will do this for you.

### Deferring Authorisation

When using multiple policies for a field, we might not want to deny resolution simply because we didn't
allow it. A third case can be useful here: defer.

If a policy does not determine that access is allowed it might choose to defer a decision so that another
policy further down the chain could still allow it. Of course, if none of the policies allow access
the request will be denied anyway.

So when should you use `deny!/1` and when should use `defer/1`?

* Use Deny:
  * When it's a hard deny (no other policy would override the decision)
  * When you only use the policy on its own
  * When it's inefficient to traverse multiple policies on a single field

* Use defer
  * When you want to combine policies
  * When you want to keep your policies flexible

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `absinthe_auth` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:absinthe_auth, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/absinthe_auth](https://hexdocs.pm/absinthe_auth).

