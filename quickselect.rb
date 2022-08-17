def quickselect(arr, left, right, k_smallest)
  return arr[left] if (left == right)
  
  random_number = (left..right).to_a.sample
  pivot_index = left + rand(right - left)
  pivot_index = partition(arr, left, right, pivot_index)

  if (k_smallest == pivot_index)
    return arr[k_smallest]
  elsif (k_smallest < pivot_index)
    return quickselect(arr, left, pivot_index - 1, k_smallest)
  end

  quickselect(arr, pivot_index + 1, right, k_smallest)
end

def partition(arr, left, right, pivot_index)
  pivot = arr[pivot_index]
  swap(arr, pivot_index, right)
  store_index = left

  (left..right).each do |i|
    if (arr[i] < pivot)
      swap(arr, store_index, i)
      store_index += 1
    end
  end

  swap(arr, store_index, right)
  store_index
end

def swap(arr, a, b)
  temp = arr[a]
  arr[a] = arr[b]
  arr[b] = temp
  arr
end

def findKthLargest(arr, k)
  size = arr.length
  quickselect(arr, 0, size - 1, size - k)
end
