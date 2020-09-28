# vlt cookbook
[![Chef cookbook](https://img.shields.io/cookbook/v/vlt.svg?style=flat-square)]()
[![license](https://img.shields.io/github/license/aspyatkin/vlt-cookbook.svg?style=flat-square)]()  
Chef helper lib to read secrets from HashiCorp's Vault

## Concept
This cookbook provides a set of utilities to obtain secrets stored in [Vault's](https://www.hashicorp.com/products/vault) K/V version 2 secret engine. Each Chef node is authenticated with an [AppRole](https://www.vaultproject.io/docs/auth/approle) method. Credentials are supposed to be stored on a Chef node in a JSON file at `/etc/vault.json`:

```json
{
  "address": "https://vault.acme.corp:8200",
  "token": "s.a9fgfdgg....",
  "approle": "database"
}
```

## Usage

```ruby
vlt = ::Vlt::Client.new(::Vlt.file_auth_provider)

template '/etc/myapp' do
  source 'myapp.conf.erb'
  ...
  templates lazy {
    {
      db_user: vlt.read('production/app_credentials', prefix: 'postgres', key: 'user'),
      db_password: vlt.read('production/app_credentials', prefix: 'postgres', key: 'password')
    }
  }
end
```

The sample above will do the following:
1. Read credentials stored in `etc/vault.json` file.
2. Authenticate on the Vault server at `<address>` using `<token>` and claim a Vault-defined role `<approle>`.
3. Read a secret at `postgres/data/production/app_credentials` and obtain 2 keys, namely `user` and `password`, from it.

## Advanced
### list secrets
Secrets can be listed within a specific path:

```ruby
vlt.list('certificate', prefix: 'tls')
```

The sample above will list secret names at `tls/metadata/certificate`.

### default prefix
One can specify a default prefix in `::Vlt::Client` constructor:

```ruby
vlt = ::Vlt::Client.new(::Vlt.file_auth_provider, 'postgres')
```

### exception handling
By default, `read` and `list` calls throw an exception if the specified path does not exist or the policy associated with the claimed `<approle>` provides insufficient permissions. This behaviour may not be suitable for every use case and can be overriden with `raise_err` option:

```ruby
vlt.read('certificate/app', prefix: 'tls', raise_err: false)  # returns nil is the secret does not exist
```

### store & obtain credentials
Default `::Vlt::file_auth_provider` is a Ruby lambda function which reads JSON at `/etc/vault.json` and returns a tuple `(<address>, <token>, <approle>)`. One may use their own scheme to store credentials and provide a function to obtain them:

```ruby
def custom_vault_auth
  lambda do
    # do something to obtain Vault credentials
    return <address>, <token>, <approle>
  end
end

vlt = ::Vlt::Client.new(custom_vault_auth)
```

## License
MIT @ [Alexander Pyatkin](https://github.com/aspyatkin)
