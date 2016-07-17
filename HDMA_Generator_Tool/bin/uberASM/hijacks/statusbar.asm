ORG $008E1A
	%clean("JML statusbar_main")
	NOP

%origin(!statusbar_freespace)
	statusbar_main:
		JSR statusbar_code
		LDA $1493           
		ORA $9D
		JML $008E1F
