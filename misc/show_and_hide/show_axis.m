function show_axis(a)
set(a, 'Visible', 'on');
achildren = get(a, 'Children');
for c = achildren
    set(c, 'Visible', 'on');
end