transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vcom -93 -work work {C:/Users/Wuql/Quartus/bricks/scripts/packages/img_coding.vhd}
vcom -93 -work work {C:/Users/Wuql/Quartus/bricks/scripts/packages/basic_settings.vhd}
vcom -93 -work work {C:/Users/Wuql/Quartus/bricks/scripts/rom_comp/rom_reader.vhd}
vcom -93 -work work {C:/Users/Wuql/Quartus/bricks/scripts/rom_comp/img_reader.vhd}

vcom -93 -work work {C:/Users/Wuql/Quartus/bricks/simulation/rom/tb.vhd}

vsim -t 1ps -L altera -L lpm -L sgate -L altera_mf -L altera_lnsim -L cycloneii -L rtl_work -L work -voptargs="+acc"  tb

do wave.do
view structure
view signals

run 100ns