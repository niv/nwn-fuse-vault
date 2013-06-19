class MyDir < Hash
    attr_accessor :name, :mode , :actime, :modtime, :uid, :gid
    def initialize(name,mode)
        @uid=0
        @gid=0
        @actime=Time.now
        @modtime=Time.now
        @xattr=Hash.new
        @name=name
        @mode=mode
    end

    def stat
        RFuse::Stat.directory(mode,:uid => uid, :gid => gid, :atime => actime, :mtime => modtime,
                              :size => size)
    end

    def listxattr()
        @xattr.keys()
    end
    def setxattr(name,value,flag)
        @xattr[name]=value #TODO:don't ignore flag
    end
    def getxattr(name)
        return @xattr[name]
    end
    def removexattr(name)
        @xattr.delete(name)
    end
    def size
        return 48 #for testing only
    end
    def isdir
        true
    end
    def insert_obj(obj,path)
        d=self.search(File.dirname(path))
        if d.isdir then
            d[obj.name]=obj
        else
            raise Errno::ENOTDIR.new(d.name)
        end
        return d
    end
    def remove_obj(path)
        d=self.search(File.dirname(path))
        d.delete(File.basename(path))
    end
    def search(path)
        p=path.split('/').delete_if {|x| x==''}
        if p.length==0 then
            return self
        else
            return self.follow(p)
        end
    end
    def follow (path_array)
        if path_array.length==0 then
            return self
        else
            d=self[path_array.shift]
            if d then
                return d.follow(path_array)
            else
                raise Errno::ENOENT.new
            end
        end
    end
    def to_s
        return "Dir: " + @name + "(" + @mode.to_s + ")"
    end
end
