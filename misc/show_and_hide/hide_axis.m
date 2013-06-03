function hide_axis(a)
set(a, 'Visible', 'off');
achildren = get(a, 'Children');
for c = achildren
    set(c, 'Visible', 'off');
end




