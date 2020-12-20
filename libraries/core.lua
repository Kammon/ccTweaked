--[[

		Core Library
			-Useful additions to existing libraries and basic functionality

--]]

local core = {}
--Define Constants
core.SLOT_COUNT = 16
core.bp = "/repos/Kammon/ccTweaked/"

-- Table Functions:

function core.join(src,dest)
    if src == dest then
        local temp = {}
        join(src,temp)
        join(temp,dest)
    else
        for k,v in pairs(src) do
            dest[#dest+1] = v
        end
    end
end


-- String Functions:

-- co-opted from http://lua-users.org/wiki/SplitJoin 'Function: true Python semantics for split' by http://lua-users.org/wiki/JoanOrdinas
function core.split(s, sSeparator, nMax, bRegexp)
   assert(sSeparator ~= '')
   assert(nMax == nil or nMax >= 1)
 
   local aRecord = {}
 
   if s:len() > 0 then
      local bPlain = not bRegexp
      nMax = nMax or -1
 
      local nField, nStart = 1, 1
      local nFirst,nLast = s:find(sSeparator, nStart, bPlain)
      while nFirst and nMax ~= 0 do
         aRecord[nField] = s:sub(nStart, nFirst-1)
         nField = nField+1
         nStart = nLast+1
         nFirst,nLast = s:find(sSeparator, nStart, bPlain)
         nMax = nMax-1
      end
      aRecord[nField] = s:sub(nStart)
   end
 
   return aRecord
end

function core.trim(s)
	return (s:gsub("^%s*(.-)%s*$", "%1"))
end


-- List Functions
function core.selectFromList(input, reference, output)
    local entries = {}
    for k,v in pairs(input) do
        if reference[input[k]]~=nil then
            -- print("entry found in input: ", input[i], " = ", reference[input[i]]) -- TEST CODE
            if type(reference[input[k]]) == "table" then
                -- print(#reference[input[k]]," entries found for",input[k]) -- TEST CODE
                core.join(reference[input[k]],entries)
            else
                core.join({reference[input[k]]},entries) --should be equivalent to the below, but using join
                --entries[(#entries+1)] = reference[input[k]]
            end
        end
        -- for k,v in ipairs(unwantedItems) do
        --  if targs[i]==k then entries = entries + v end
        -- end
    end
    core.join(entries,output)
    --return output
end

-- send the library out to the calling require
return core
