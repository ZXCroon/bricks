onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb/fclk
add wave -noupdate /tb/datain
add wave -noupdate /tb/clkin
add wave -noupdate /tb/rstin
add wave -noupdate -expand -group internal -radix hexadecimal /tb/tentity/scancode
add wave -noupdate -expand -group internal /tb/tentity/leftp
add wave -noupdate -expand -group internal /tb/tentity/rightp
add wave -noupdate -expand -group internal /tb/tentity/shiftp
add wave -noupdate -expand -group internal /tb/tentity/isbreak
add wave -noupdate -group output /tb/confirm
add wave -noupdate -group output /tb/quit
add wave -noupdate -group output /tb/upp
add wave -noupdate -group output /tb/downp
add wave -noupdate -group output /tb/board_speed
add wave -noupdate /tb/tentity/dataok
add wave -noupdate /tb/tentity/kb/state
add wave -noupdate /tb/tentity/kb/code
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {180110 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {118290 ps} {267290 ps}
