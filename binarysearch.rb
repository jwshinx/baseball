# average o(n), worst case o(n**2)
def k_closest_binary_search(arr, k)
  remaining = []
  arr.each_index{ |idx| remaining << idx }
  low = 0
  high = arr.max
  closest = []

  while (k > 0) do
    mid = low + ((high.to_f - low.to_f) / 2.0).round(2)

    closer, farther = split_values(remaining, arr, mid)
    if (closer.length > k)
      remaining = closer
      high = mid
    else
      k -= closer.length
      closest.push(closer.clone).flatten!
      remaining = farther
      low = mid
    end
  end

  closest.map{|idx| arr[idx]}
end

def split_values(remaining, numbers, mid)
  closer, farther = [], []
  remaining.each do |idx|
    if (numbers[idx] <= mid)
      closer << idx
    else
      farther << idx
    end
  end

  [closer, farther]
end