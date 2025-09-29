clear;

weight = [2 2 3 5 5];

small_points = weight.*[1 2 5 1 5];
medium_points = weight.*[4 5 4 4 3];
large_points = weight.*[5 2 1 5 1];

small = [small_points(1)]; medium = [medium_points(1)]; large = [large_points(1)];

for i = 2:5
    small(i) = small(i-1) + small_points(i);
    medium(i) = medium(i-1) + medium_points(i);
    large(i) = large(i-1) + large_points(i);
end

x_labels = ['Testing Frequency' 'Amount of Size Options' 'Affordability' 'Arrangement Feasibility' 'Sustainability'];
x = 1:5;

figure()

plot(x, small); hold on;
plot(x, medium); hold on;
plot(x, large); hold on;

legend('Many Small Payloads', 'Mixed Bag', 'Few Large Payloads', 'location', 'best');