library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_signed.all;

package geometry is
	type vector is array(0 to 1) of integer;
	subtype point is vector;
	
	function construct_vector(x, y: integer) return vector;
	function construct_point(x, y: integer) return point;
	function "+"(va, vb: vector) return vector;
	function "-"(va, vb: vector) return vector;
	function "-"(v: vector) return vector;
	function "*"(v: vector; k: integer) return vector;
	function "*"(k: integer; v: vector) return vector;
end geometry;

package body geometry is


function construct_vector(x, y: integer) return vector is
	variable v: vector;
begin
	v(0) := x;
	v(1) := y;
	return v;
end construct_vector;

function construct_point(x, y: integer) return point is
	variable p: point;
begin
	p(0) := x;
	p(1) := y;
	return p;
end construct_point;

function "+"(va, vb: vector) return vector is
	variable v: vector;
begin
	v(0) := va(0) + vb(0);
	v(1) := va(1) + vb(1);
	return v;
end "+";

function "-"(va, vb: vector) return vector is
	variable v: vector;
begin
	v(0) := va(0) - vb(0);
	v(1) := va(1) - vb(1);
	return v;
end "-";

function "-"(v: vector) return vector is
	variable v1: vector;
begin
	v1(0) := -v(0);
	v1(1) := -v(1);
	return v1;
end "-";

function "*"(v:vector; k: integer) return vector is
	variable v1: vector;
begin
	v1(0) := v(0) * k;
	v1(1) := v(1) * k;
	return v1;
end "*";

function "*"(k: integer; v: vector) return vector is
begin
	return v * k;
end "*";



end geometry;