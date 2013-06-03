function checked = is_checked(h)
val = get(h, 'Checked');
if(strcmp(val, 'off'))
    checked = 0;
else
    checked = 1;
end