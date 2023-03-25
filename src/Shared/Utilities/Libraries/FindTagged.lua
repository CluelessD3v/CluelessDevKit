type array<T> = {number: T}

local CollectionService = game:GetService("CollectionService")

local module = {}

local function handleException(parent, tag)
    assert(typeof(parent) == "Instance", tostring(parent).."Is not of type Instance")
    assert(typeof(tag) == "string", tostring(tag).." Is not a string")
end


-- Returns the first descendant with the given tag within the given parent
module.Descendant = function(parent: Instance, tag: string): Instance
    handleException(parent, tag)
    for _, child: Instance in parent:GetDescendants() do
        if CollectionService:HasTag(child, tag) then
            return child 
        end
    end 
end

-- Returns the first descendant of the given class with the given class within the given parent
module.DescendantOfClass = function(parent: Instance, tag: string, className): Instance
    handleException(parent, tag)
    for _, descendant: Instance in parent:GetDescendants() do
        if CollectionService:HasTag(descendant, tag) and descendant.ClassName == className then
            return descendant 
        end
    end 
end





-- Returns an array of all descendants with the given tag within the given parent
module.Descendants = function(parent: Instance, tag: string): Array<Instance>
    handleException(parent, tag)
    
    local taggedDescendants = {}

    for _, descendant: Instance in parent:GetDescendants() do
        if CollectionService:HasTag(descendant, tag) then
            table.insert(taggedDescendants, descendant)
        end
    end 

    return taggedDescendants
end

-- Returns an array of all descendants of the given class with the given tag within the given parent
module.DescendantsOfClass = function(parent: Instance, tag: string, className): Array<Instance>
    handleException(parent, tag)

    local taggedDescendantsOfGivenClass = {}

    for _, descendant: Instance in parent:GetDescendants() do 
        if CollectionService:HasTag(descendant, tag) and descendant.ClassName == className then
            table.insert(taggedDescendantsOfGivenClass, descendant)
        end
    end 

    return taggedDescendantsOfGivenClass
end





-- Returns the first child with the given tag within the given parent
module.Child = function(parent: Instance, tag: string): Instance
    handleException(parent, tag)

    for _, child: Instance in parent:GetChildren() do
        if CollectionService:HasTag(child, tag) then 
            return child 
        end
    end
end

-- Returns the first descendant of the given class with the given tag within the given parent
module.ChildOfClass = function(parent: Instance, tag: string, className): Instance
    for _, child: Instance in parent:GetChildren() do
        if CollectionService:HasTag(child, tag) and child.ClassName == className then 
            return child 
        end
    end
end





-- Returns an array of all children with the given tag within the given parent
module.Children = function(parent: Instance, tag: string): Array<Instance>
    handleException(parent, tag)

    local taggedChildren = {}

    for _, child: Instance in parent:GetChildren() do
        if CollectionService:HasTag(child, tag) then 
            table.insert(taggedChildren, child) 
        end
    end

    return taggedChildren
end

-- Returns an array of all children of the given class with the given tag within the given parent
module.ChildrenOfClass = function(parent: Instance, tag: string, className): Array<Instance>
    handleException(parent, tag)

    local taggedChildrenOfGivenClass = {}

    for _, child: Instance in parent:GetChildren() do
        if CollectionService:HasTag(child, tag) and child.ClassName == className then 
            table.insert(taggedChildrenOfGivenClass, child) 
        end
    end

    return taggedChildrenOfGivenClass
end



return module
