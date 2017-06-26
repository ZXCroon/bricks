transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vcom -93 -work work {C:/Users/Wuql/Quartus/bricks/scripts/keyboard_comp/KeyboardReader.vhd}
vcom -93 -work work {C:/Users/Wuql/Quartus/bricks/scripts/packages/key_coding.vhd}
vcom -93 -work work {C:/Users/Wuql/Quartus/bricks/scripts/modules/keyboard_decoder.vhd}

vcom -93 -work work {C:/Users/Wuql/Quartus/bricks/simulation/keyboard/tb.vhd}

vsim -L altera -L lpm -L sgate -L altera_mf -L altera_lnsim -L cycloneii -L rtl_work -L work -voptargs="+acc"  tb

do wave.do

view structure
view signals

run 800ns