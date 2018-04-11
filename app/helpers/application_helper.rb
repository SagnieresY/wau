module ApplicationHelper
	# Will cumulate an array of month+data array [[JAN, 0], [FEB, 1]..]
	def cumulate_my_array(array_of_array)
		sum = 0
		array_of_array.map do |array|
			sum += array[1]
			array[1] = sum
			array
		end
	end

	def cumulate_my_hash(my_hash)
		sum = 0
		my_hash.each do |key,value| 
			sum += value
			p sum 
			my_hash[key] = sum
		end
	end

	def year_range(year)
		t = Time.new(year,1,1,0,0,0,'+00:00')
		t.beginning_of_year..t.end_of_year
	end
end
