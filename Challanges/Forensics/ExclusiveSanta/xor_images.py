import cv2

foo = cv2.imread("./1.png")
bar = cv2.imread("./CCB6.png")

key = cv2.bitwise_xor(foo, bar)
cv2.imshow("xored data", key)
