.section .text
.global testvector
.type testvector, @function

testvector:
        vadd.vv v10, v11, v12
        ret
