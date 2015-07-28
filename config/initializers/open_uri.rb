# Forces open() to return an IO instead of a StringIO.
OpenURI::Buffer.send :remove_const, 'StringMax'
OpenURI::Buffer.const_set 'StringMax', 0