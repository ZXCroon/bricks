onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb/x
add wave -noupdate /tb/y
add wave -noupdate /tb/img
add wave -noupdate /tb/inclk
add wave -noupdate /tb/outclk
add wave -noupdate /tb/dataok
add wave -noupdate /tb/r
add wave -noupdate /tb/g
add wave -noupdate /tb/b
add wave -noupdate /tb/q
add wave -noupdate /tb/qqq
add wave -noupdate /tb/tentity/state
add wave -noupdate -radix unsigned /tb/tentity/address
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {29971 ps} 0}
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
WaveRestoreZoom {0 ps} {46 ns}
