module HackyHAL
  module Util
    def self.object_from_hash(hash, context_module)
      hash = hash.dup
      type = hash.delete(:type)

      unless type
        raise ArgumentError, "Must specify type to build object from hash.  Given: #{hash}"
      end

      context_module.const_get(type).new(hash)
    end

    def self.symbolize_keys_deep(h)
      h.keys.each do |k|
        ks = k.respond_to?(:to_sym) ? k.to_sym : k
        h[ks] = h.delete(k)
        symbolize_keys_deep(h[ks]) if h[ks].kind_of?(Hash)
      end
      h
    end
  end
end
