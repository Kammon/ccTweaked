--things like join, split, selectFromTable, etc will live here

--table utility functions
function table:print()
    assert(type(self)=="table")
    print("\nkey\t\t\tvalue")
    print("---\t\t\t-----")
    for k,v in next, self do
        print(k,"\t\t\t",v)
        --os.sleep(1) -- because cc terminals have garbage height and no scroll capability
        if type(v)=="table" then
            table.print(v)
        end
    end
    print("")
end
