require 'vault'
require 'json'

module Vlt
  def self.file_auth_provider(path = '/etc/vault.json')
    return lambda do
      data = ::JSON.parse(::File.read(path))
      return data['address'], data['token'], data['approle']
    end
  end

  class Client
    def initialize(auth_provider_func, default_prefix = nil)
      @auth_provider_func = auth_provider_func
      @default_prefix = default_prefix
      @client = nil
    end

    def read(path, prefix: nil, key: nil, raise_err: true)
      init_client if @client.nil?

      resolved_path = path
      unless @default_prefix.nil?
        resolved_path = "#{@default_prefix}/data/#{path}"
      end
      unless prefix.nil?
        resolved_path = "#{prefix}/data/#{path}"
      end

      r = nil
      begin
        r = @client.logical.read(resolved_path).data[:data]
        unless key.nil?
          r = r[key.to_sym]
        end
      rescue ::Vault::HTTPClientError => e
        err_msg = "Vlt: failed to read data at #{e.address}/#{resolved_path} (HTTP status code: #{e.code})"
        if raise_err
          ::Chef::Application.fatal!(err_msg, 1)
        else
          ::Chef::Log.warn(err_msg)
        end
      end

      r
    end

    protected
    def init_client
      address, token, approle = @auth_provider_func.call
      @client = ::Vault::Client.new(address: address, token: token)
      approle_id = @client.approle.role_id(approle)
      secret_id = (@client.approle.create_secret_id(approle)).data[:secret_id]
      @client.auth.approle(approle_id, secret_id)
    end
  end
end
