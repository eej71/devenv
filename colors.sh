#!/bin/bash
echo -e "Plain"
echo -e "\e[1mbold\e[0m"
echo -e "\e[3mitalic\e[0m"
echo -e "\e[3m\e[1mbold italic\e[0m"
echo -e "\e[4munderline\e[0m"
echo -e "\e[5mslow blink\e[0m"
echo -e "\e[6mfast blink\e[0m"
echo -e "\e[9mstrikethrough\e[0m"
echo -e "\e[21mdouble underline\e[0m"
echo -e "\e[31mHello World\e[0m"
echo -e "\x1B[31mHello World\e[0m"
echo -e "\e[53moverbar\e[0m"
echo -e "\e[4m\e[53moverunder\e[0m"
echo -e "\e[2mfaint\e[0m"

# Show the color range
awk -v term_cols="${width:-$(tput cols || echo 80)}" 'BEGIN{
    s="/\\";
    for (colnum = 0; colnum<term_cols; colnum++) {
        r = 255-(colnum*255/term_cols);
        g = (colnum*510/term_cols);
        b = (colnum*255/term_cols);
        if (g>255) g = 510-g;
        printf "\033[48;2;%d;%d;%dm", r,g,b;
        printf "\033[38;2;%d;%d;%dm", 255-r,255-g,255-b;
        printf "%s\033[0m", substr(s,colnum%2+1,1);
    }
    printf "\n";
}'
