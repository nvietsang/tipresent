.data
T:
	.byte 0xc, 0xc, 0x2, 0x2, 0xc, 0xc, 0xc, 0xc, 0xc, 0xc, 0x6, 0x6, 0x8, 0x8, 0xc, 0xc
	.byte 0x9, 0x9, 0x7, 0x7, 0x9, 0x9, 0x9, 0x9, 0x9, 0x9, 0x3, 0x3, 0xd, 0xd, 0x9, 0x9
	.byte 0xe, 0xe, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0xa, 0xa, 0x0, 0x0, 0x0, 0x0, 0x4, 0x4
	.byte 0xb, 0xb, 0x5, 0x5, 0x5, 0x5, 0x5, 0x5, 0xf, 0xf, 0x5, 0x5, 0x5, 0x5, 0x1, 0x1
	.byte 0xa, 0xa, 0xa, 0xa, 0xa, 0xa, 0x4, 0x4, 0xe, 0xe, 0xa, 0xa, 0xa, 0xa, 0x0, 0x0
	.byte 0xf, 0xf, 0xf, 0xf, 0xf, 0xf, 0x1, 0x1, 0xb, 0xb, 0xf, 0xf, 0xf, 0xf, 0x5, 0x5
	.byte 0x8, 0x8, 0x8, 0x8, 0x6, 0x6, 0x8, 0x8, 0x8, 0x8, 0xc, 0xc, 0x2, 0x2, 0x8, 0x8
	.byte 0xd, 0xd, 0xd, 0xd, 0x3, 0x3, 0xd, 0xd, 0xd, 0xd, 0x9, 0x9, 0x7, 0x7, 0xd, 0xd
	.byte 0x6, 0x6, 0xc, 0xc, 0x2, 0x2, 0x6, 0x6, 0x6, 0x6, 0x8, 0x8, 0x6, 0x6, 0x6, 0x6
	.byte 0x3, 0x3, 0x9, 0x9, 0x7, 0x7, 0x3, 0x3, 0x3, 0x3, 0xd, 0xd, 0x3, 0x3, 0x3, 0x3
	.byte 0x4, 0x4, 0xe, 0xe, 0xe, 0xe, 0xa, 0xa, 0x0, 0x0, 0xe, 0xe, 0xe, 0xe, 0xe, 0xe
	.byte 0x1, 0x1, 0xb, 0xb, 0xb, 0xb, 0xf, 0xf, 0x5, 0x5, 0xb, 0xb, 0xb, 0xb, 0xb, 0xb
	.byte 0x0, 0x0, 0x4, 0x4, 0x4, 0x4, 0xe, 0xe, 0x4, 0x4, 0x4, 0x4, 0x4, 0x4, 0xa, 0xa
	.byte 0x5, 0x5, 0x1, 0x1, 0x1, 0x1, 0xb, 0xb, 0x1, 0x1, 0x1, 0x1, 0x1, 0x1, 0xf, 0xf
	.byte 0x2, 0x2, 0x6, 0x6, 0x8, 0x8, 0x2, 0x2, 0x2, 0x2, 0x2, 0x2, 0xc, 0xc, 0x2, 0x2
	.byte 0x7, 0x7, 0x3, 0x3, 0xd, 0xd, 0x7, 0x7, 0x7, 0x7, 0x7, 0x7, 0x9, 0x9, 0x7, 0x7
	
A:
    .byte 0x8, 0xF, 0xD, 0xA, 0xC, 0xB, 0x9, 0xE, 0x4, 0x3, 0x1, 0x6, 0x0, 0x7, 0x5, 0x2

.text
.global add_roundkey
.type add_roundkey, %function
add_roundkey:
	@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	@ AddRoundKey
	@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	
	@ ARK for 1st share
	ldr r2, [r0]		@p1
	ldr r3, [r0, #4]
	ldr r4, [r0, #28]	@k1
	ldr r5, [r0, #32]
	eor r2, r2, r4
	eor r3, r3, r5
	str r2, [r0]
	str r3, [r0, #4]
	
	@ ARK for 2nd share
	ldr r4, [r0, #8] 	@p2
	ldr r5, [r0,#12]
	ldr r2, [r0,#40]	@k2
	ldr r3, [r0,#44]
	eor r2, r2, r4
	eor r3, r3, r5
	str r2, [r0, #8]
	str r3, [r0,#12]
	
	@ ARK for 3rd share
	ldr r2, [r0,#16]	@p3
	ldr r3, [r0,#20]
	ldr r4, [r0,#52]	@k3
	ldr r5, [r0,#56]
	eor r4, r4, r2
	eor r5, r5, r3
	str r4, [r0,#16]
	str r5, [r0,#20]
	
	bx lr


.global sboxpair
.type sboxpair, %function
sboxpair:
	ldr r2, =T
	ldr r3, =A
	ldr r1, [r0, #60]
	
	push {r4-r7}

	@
	@ Sbox 0
	@
	
	@ Use r7 as mask, r6 as tmp
	@ Lookup T->A
	ldrb r4, [r0, r1]	@ 1st inpshare
	mov r7, #0xF
	and r4, r4, r7
	mov r7, #8
	add r6, r1, r7
	ldrb r5, [r0, r6]	@ 2nd inpshare
	mov r7, #0xF
	and r5, r5, r7
	lsl r4, r4, #4
	add r4, r4, r5
	ldrb r4, [r2, r4]	@ Lookup T
	ldrb r4, [r3, r4]	@ Lookup A
	mov r10, r4			@ Result: 3rd outshare
	
	mov r7, #16
	add r6, r1, r7
	ldrb r4, [r0, r6]	@ 3rd inpshare
	mov r7, #0xF
	and r4, r4, r7
	lsl r5, r5, #4
	add r5, r5, r4
	ldrb r5, [r2, r5]	@ Lookup T
	ldrb r5, [r3, r5]	@ Lookup A
	mov r8, r5			@ Result: 1st outshare
	
	ldrb r5, [r0, r1]	@ 1st inpshare
	and r5, r5, r7
	lsl r4, r4, #4
	add r4, r4, r5
	ldrb r4, [r2, r4]	@ Lookup T
	ldrb r4, [r3, r4]	@ Lookup A
	mov r9, r4			@ Result: 2st outshare
	
	@ Lookup T
	mov r5, r8 			@ 1st share
	lsl r5, r5, #4
	add r5, r5, r4
	ldrb r5, [r2, r5]	@ Result: 3rd outshare
	@ Store 3rd outshare
	mov r7, #16
	add r6, r1, r7
	ldrb r6, [r0, r6]
	mov r7, #0xF0
	and r6, r6, r7
	eor r6, r6, r5
	mov r7, #16
	add r5, r1, r7
	strb r6, [r0, r5]
	
	mov r5, r9 			@ 2nd share
	mov r4, r10 		@ 3rd share
	lsl r5, r5, #4
	add r5, r5, r4
	ldrb r5, [r2, r5]	@ Result: 1st outshare
	@ Store 1st outshare
	ldrb r6, [r0, r1]
	mov r7, #0xF0
	and r6, r6, r7
	eor r6, r6, r5
	strb r6, [r0, r1]
	
	mov r5, r10 		@ 3rd share
	mov r4, r8 			@ 1st share
	lsl r5, r5, #4
	add r5, r5, r4
	ldrb r5, [r2, r5]	@ Result: 2nd outshare
	@ Store 2nd outshare
	mov r7, #8
	add r6, r1, r7
	ldrb r6, [r0, r6]
	mov r7, #0xF0
	and r6, r6, r7
	eor r6, r6, r5
	mov r7, #8
	add r5, r1, r7
	strb r6, [r0, r5]	

	@
	@ Sbox 1
	@
	
	@ Lookup T->A
	ldrb r4, [r0, r1]	@ 1st inpshare
	lsr r4, r4, #4
	mov r7, #0x8
	add r6, r1, r7
	ldrb r5, [r0, r6]	@ 2nd inpshare
	lsr r5, r5, #4
	lsl r4, r4, #4
	add r4, r4, r5
	ldrb r4, [r2, r4]	@ Lookup T
	ldrb r4, [r3, r4]	@ Lookup A
	mov r10, r4			@ Result: 3rd outshare
	
	mov r7, #16
	add r6, r1, r7
	ldrb r4, [r0, r6]	@ 3rd inpshare
	lsr r4, r4, #4
	lsl r5, r5, #4
	add r5, r5, r4
	ldrb r5, [r2, r5]	@ Lookup T
	ldrb r5, [r3, r5]	@ Lookup A
	mov r8, r5			@ Result: 1st outshare
	
	ldrb r5, [r0, r1]	@ 1st inpshare
	lsr r5, r5, #4
	lsl r4, r4, #4
	add r4, r4, r5
	ldrb r4, [r2, r4]	@ Lookup T
	ldrb r4, [r3, r4]	@ Lookup A
	mov r9, r4			@ Result: 2st outshare
	
	@ Lookup T
	mov r5, r8 			@ 1st share
	lsl r5, r5, #4
	add r5, r5, r4
	ldrb r5, [r2, r5]	@ Result: 3rd outshare
	lsl r5, r5, #4
	@ Store 3rd outshare
	mov r7, #16
	add r6, r1, r7
	ldrb r6, [r0, r6]
	mov r7, #0x0F
	and r6, r6, r7
	eor r6, r6, r5
	mov r7, #16
	add r5, r1, r7
	strb r6, [r0, r5]
	
	mov r5, r9 			@ 2nd share
	mov r4, r10 		@ 3rd share
	lsl r5, r5, #4
	add r5, r5, r4
	ldrb r5, [r2, r5]	@ Result: 1st outshare
	lsl r5, r5, #4
	@ Store 1st outshare
	ldrb r6, [r0, r1]
	mov r7, #0x0F
	and r6, r6, r7
	eor r6, r6, r5
	strb r6, [r0, r1]
	
	mov r5, r10 		@ 3rd share
	mov r4, r8 			@ 1st share
	lsl r5, r5, #4
	add r5, r5, r4
	ldrb r5, [r2, r5]	@ Result: 2nd outshare
	lsl r5, r5, #4
	@ Store 2nd outshare
	mov r7, #8
	add r6, r1, r7
	ldrb r6, [r0, r6]
	mov r7, #0x0F
	and r6, r6, r7
	eor r6, r6, r5
	mov r7, #8
	add r5, r1, r7
	strb r6, [r0, r5]	

	pop {r4-r7}
	bx lr
	
	
.global playerbyte
.type playerbyte, %function
playerbyte:
	push {r4-r7}

	mov r1, #60
	ldrb r1, [r0, r1]

	mov r5, #61
	ldrb r5, [r0, r5] 

	@ byte 0
	ldr r4, [r0, r1]
	mov r3, r5
	and r3, r3, r4	
	mov r6, r3
	lsl r3, r5, #4
	and r3, r3, r4
	lsr r3, r3, #3
	eor r6, r6, r3
	lsl r3, r5, #8
	and r3, r3, r4
	lsr r3, r3, #6
	eor r6, r6, r3
	lsl r3, r5, #12
	and r3, r3, r4
	lsr r3, r3, #9
	eor r6, r6, r3
	lsl r3, r5, #16
	and r3, r3, r4
	lsr r3, r3, #12
	eor r6, r6, r3
	lsl r3, r5, #20
	and r3, r3, r4
	lsr r3, r3, #15
	eor r6, r6, r3
	lsl r3, r5, #24
	and r3, r3, r4
	lsr r3, r3, #18
	eor r6, r6, r3
	lsl r3, r5, #28
	and r3, r3, r4
	lsr r3, r3, #21
	eor r6, r6, r3
	clz r3, r5
	rsb r3, r3, #31
	lsr r6, r6, r3
	mov r3, #63
	strb r6, [r0, r3]

	pop {r4-r7}
	bx lr

.global key_schedule
.type key_schedule, %function
key_schedule:
	push {r4-r7}

	@Rotation
	ldr r1, [r0, #24]
	ldr r2, [r0, #28]
	ldr r3, [r0, #32]
	@ Results in r4, r5, r6, use r7 as tmp
	lsl r6, r2, #29
	lsr r7, r1, #3
	eor r6, r6, r7
	lsr r7, r3, #19
	eor r6, r6, r7
	lsl r5, r3, #13
	lsr r7, r2, #19
	eor r5, r5, r7
	lsr r4, r2, #3
	lsl r4, r4, #16
	mov r1, #0
	mov r2, #0
	mov r3, #0
	str r4, [r0, #24]
	str r5, [r0, #28]
	str r6, [r0, #32]
	
	ldr r1, [r0, #36]
	ldr r2, [r0, #40]
	ldr r3, [r0, #44]
	@ Results in r4, r5, r6, use r7 as tmp
	lsl r6, r2, #29
	lsr r7, r1, #3
	eor r6, r6, r7
	lsr r7, r3, #19
	eor r6, r6, r7
	lsl r5, r3, #13
	lsr r7, r2, #19
	eor r5, r5, r7
	lsr r4, r2, #3
	lsl r4, r4, #16
	mov r1, #0
	mov r2, #0
	mov r3, #0
	str r4, [r0, #36]
	str r5, [r0, #40]
	str r6, [r0, #44]
	
	ldr r1, [r0, #48]
	ldr r2, [r0, #52]
	ldr r3, [r0, #56]
	@ Results in r4, r5, r6, use r7 as tmp
	lsl r6, r2, #29
	lsr r7, r1, #3
	eor r6, r6, r7
	lsr r7, r3, #19
	eor r6, r6, r7
	lsl r5, r3, #13
	lsr r7, r2, #19
	eor r5, r5, r7
	lsr r4, r2, #3
	lsl r4, r4, #16
	mov r1, #0
	mov r2, #0
	mov r3, #0
	str r4, [r0, #48]
	str r5, [r0, #52]
	str r6, [r0, #56]
	
	@ Sbox
	ldr r2, =T
	ldr r3, =A
	
	mov r1, #35
	ldrb r4, [r0, r1]	@ 1st inpshare
	lsr r4, r4, #4
	mov r1, #47
	ldrb r5, [r0, r1]	@ 2nd inpshare
	lsr r5, r5, #4
	lsl r4, r4, #4
	add r4, r4, r5
	ldrb r4, [r2, r4]
	ldrb r4, [r3, r4]
	mov r9, r4			@ Result: 3st outshare to r9
	
	mov r1, #59
	ldrb r4, [r0, r1]	@ 3rd inpshare
	lsr r4, r4, #4
	lsl r5, r5, #4
	add r5, r5, r4
	ldrb r5, [r2, r5]	@ Lookup T
	ldrb r5, [r3, r5]	@ Lookup A
	mov r7, r5			@ Result: 1st outshare to r7
	
	mov r1, #35
	ldrb r5, [r0, r1]	@ 1st inpshare
	lsr r5, r5, #4
	lsl r4, r4, #4
	add r4, r4, r5
	ldrb r4, [r2, r4]	@ Lookup T
	ldrb r4, [r3, r4]	@ Lookup A
	mov r8, r4			@ Result: 2st outshare to r8
	
	@ Lookup T
	mov r4, r7
	mov r5, r8
	lsl r4, r4, #4
	add r4, r4, r5
	ldrb r4, [r2, r4] 	@ 3rd outshare
	mov r1, #59
	ldrb r5, [r0, r1]
	mov r6, #0x0F
	and r5, r5, r6
	lsl r4, r4, #4
	eor r5, r5, r4
	strb r5, [r0, r1]
	
	mov r4, r8
	mov r5, r9
	lsl r4, r4, #4
	add r4, r4, r5
	ldrb r4, [r2, r4] 	@ 1st outshare
	mov r1, #35
	ldrb r5, [r0, r1]
	mov r6, #0x0F
	and r5, r5, r6
	lsl r4, r4, #4
	eor r5, r5, r4
	strb r5, [r0, r1]
	
	mov r4, r9
	mov r5, r7
	lsl r4, r4, #4
	add r4, r4, r5
	ldrb r4, [r2, r4] 	@ 2nd outshare
	mov r1, #47
	ldrb r5, [r0, r1]
	mov r6, #0x0F
	and r5, r5, r6
	lsl r4, r4, #4
	eor r5, r5, r4
	strb r5, [r0, r1]
	
	@ Round constant
	mov r4, #60
	ldrb r1, [r0, r4]
	mov r4, #27
	ldrb r2, [r0, r4]
	mov r3, #1
	and r3, r3, r1
	lsl r3, r3, #7
	eor r2, r2, r3
	mov r4, #27
	strb r2, [r0, r4]
	mov r4, #28
	ldrb r2, [r0, r4]
	lsr r1, r1, #1
	eor r2, r2, r1
	strb r2, [r0, r4]

	pop {r4-r7}
	bx lr	
	
	
	
	