  global _str_1
  global _str_2
  global _scrollstr_desc_1
  global _scrollstr_desc_2

.scrollstr_desc  idata
_str_1				db 'T', 'e', 's', 't', ' ', 's', 'c', 'r', 'o', 'l', 'l', 's', 't', 'r', 0x00
_str_2				db 'A', 'n', 'o', 't', 'h', 'e', 'r', ' ', 't', 'e', 's', 't', 0x00

_scrollstr_desc_1	db 0x02			; counter
			db 0x02			; timeout
			db low(_test_stub_step)	; step
			db high(_test_stub_step)
			db upper(_test_stub_step)
			db 16			; width
			db 0			; y
			db 0			; x
			db low(_str_1)		; str
			db high(_str_1)
			db 0			; i
			db 1			; charoff
			db 0x80			; mask
			db low(_test_stub_stop)	; end
			db high(_test_stub_stop)
			db upper(_test_stub_stop)
			db 0x00			; bitmap_mask

_scrollstr_desc_2	db 0x02			; counter
			db 0x02			; timeout
			db low(_test_stub_step)	; step
			db high(_test_stub_step)
			db upper(_test_stub_step)
			db 16			; width
			db 0			; y
			db 16			; x
			db low(_str_2)		; str
			db high(_str_2)
			db 0			; i
			db 1			; charoff
			db 0x80			; mask
			db low(_test_stub_stop)	; end
			db high(_test_stub_stop)
			db upper(_test_stub_stop)
			db 0x00			; bitmap_mask
