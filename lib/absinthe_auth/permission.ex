defprotocol AbsintheAuth.Permission do
  def allow?(object, permission, resolution)
end
