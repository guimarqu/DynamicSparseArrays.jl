"""
    insert!(array, key, value, from, to, seg_cap, semaphores)

Insert the element `(key, value)` in the subarray of `array` starting at 
position `from` and ending at position `to` included.

Return the position where the element is located and a boolean equal to `true`
if it is a new `key`.
"""
function insert!(
    array::Elements{K,T}, key::K, value, from::Int, to::Int, semaphores
) where {K,T}
    (pos, _) = find(array, key, from, to)
    if _getkey(array, pos) == key
        array[pos] = (key, value)
        return (pos, false)
    end

    # insert the new key after the one found by the binary search
    return _insert!(array, key, value, pos, semaphores)
end

function _insert!(
    array::Elements{K,T}, key::K, value, pos::Int, semaphores
) where {K,T}
    insertion_pos = pos
    next_empty_pos = _nextemptypos(array, pos)
    if next_empty_pos != 0
        _movecellstoright!(array, pos+1, next_empty_pos, semaphores)
        array[pos+1] = (key, value)
        insertion_pos += 1
    else
        previous_empty_pos = _previousemptypos(array, pos)
        if previous_empty_pos != 0
            _movecellstoleft!(array, pos, previous_empty_pos, semaphores)
            array[pos] = (key, value)
        else
            error("No empty cell to insert a new element in the PMA.") # Should not occur thanks to density.
        end
    end
    return (insertion_pos, true)
end

function insert!(array::Elements{K,T}, key::K, value, semaphores) where {K,T}
    return insert!(array, key, value, 1, length(array), semaphores)
end