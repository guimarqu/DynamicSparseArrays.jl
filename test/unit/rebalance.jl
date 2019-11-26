function test_rebalance(capacity::Int, expnbempty::Int)
    array, nbempty, nbcells = array_factory(capacity, expnbempty)
    DynamicSparseArrays._pack!(array, 1, length(array), nbcells)
    for i in 1:nbcells
        @test array[i][1] == i
    end

    DynamicSparseArrays._spread!(array, 1, length(array), nbcells)
    c = 0
    i = 1
    for j in 1:capacity
        if array[j] == nothing
            c += 1
        else
            (key, val) = array[j]
            @test key == i
            i += 1
        end
    end
    @test nbempty == c
    return
end

function test_rebalance_with_semaphores(capacity::Int, expnbempty::Int)
    array, sem, nbempty, nbcells = partitioned_array_factory(capacity, expnbempty)

    for pos in sem
        @test array[pos][1] == 0
    end

    DynamicSparseArrays._pack!(array, 1, length(array), nbcells)
    DynamicSparseArrays._spread!(array, 1, length(array), nbcells, sem)
    c = 0
    i = 1
    for j in 1:capacity
        if array[j] == nothing
            c += 1
        else
            (key, val) = array[j]
            if key != 0
                @test key == i
                i += 1
            else 
                i = 1
            end
        end
    end
    @test nbempty == c

    for pos in sem
        @test array[pos][1] == 0
    end
    return
end