flag = "ƃŰŶŉůļźŞŷŭŪƄŰŘŰŧŖŔŦĦŨĬƀźōşŋůĲňĳźĖőƃũťũŸŪĞ"
flag = [~(c^i)*(-int(1/(5**0.5) * ((1 + 5**0.5)**1 / 2 - (1 - 5**0.5)**1 / 2))) + len(flag) * 6 + 15 for i, c in enumerate([ord(a) for a in flag[::-int(1/(5**0.5) * ((1 + 5**0.5)**1 / 2 - (1 - 5**0.5)**1 / 2))]])]
for i in flag:
	print(chr(i), end="")

#  0CTF{___R___E__D___A___C____T_____E____D______}