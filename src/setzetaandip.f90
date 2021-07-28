!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!
!   EVB-QMDFF - RPMD molecular dynamics and rate constant calculations on
!               black-box generated potential energy surfaces
!
!   Copyright (c) 2021 by Julien Steffen (steffen@pctc.uni-kiel.de)
!                         Stefan Grimme (grimme@thch.uni-bonn.de) (QMDFF code)
!
!   Permission is hereby granted, free of charge, to any person obtaining a
!   copy of this software and associated documentation files (the "Software"),
!   to deal in the Software without restriction, including without limitation
!   the rights to use, copy, modify, merge, publish, distribute, sublicense,
!   and/or sell copies of the Software, and to permit persons to whom the
!   Software is furnished to do so, subject to the following conditions:
!
!   The above copyright notice and this permission notice shall be included in
!   all copies or substantial portions of the Software.
!
!   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
!   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
!   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
!   THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
!   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
!   FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
!   DEALINGS IN THE SOFTWARE.
!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

!
!     subroutine setZETAandIP: Defines needed parameter arrays for EHT calculation
!
!     part of QMDFF
!
subroutine setZETAandIP
use qmdff
implicit none
real(kind=8) dum1,dum2

!
!    default values: zero
!
zet=0.0d0
ip=0.0d0
!
!     Hermans Slater exponents : A. Herman, Modelling Simul. Mater. Sci. Eng. 12 (2004) 21–32
!     EMPIRICAL Tue Jun 10 21:39:28 CEST 2014
!     for 86 different elements!
!
zet(1,1)=1.25
zet(2,1)=1.6469 
zet(3,1)=0.6534; zet(3,2)=0.5305
zet(4,1)=1.0365; zet(4,2)=0.8994
zet(5,1)=1.3990; zet(5,2)=1.2685
zet(6,1)=1.7210; zet(6,2)=1.6105
zet(7,1)=2.0348; zet(7,2)=1.9398
zet(8,1)=2.2399; zet(8,2)=2.0477
zet(9,1)=2.5644; zet(9,2)=2.4022
zet(10,1)=2.8812; zet(10,2)=2.7421
zet(11,1)=0.8675; zet(11,2)=0.6148
zet(12,1)=1.1935; zet(12,2)=0.8809
zet(13,1)=1.5143; zet(13,2)=1.1660
zet(14,1)=1.7580; zet(14,2)=1.4337
zet(15,1)=1.9860; zet(15,2)=1.6755
zet(16,1)=2.1362; zet(16,2)=1.7721
zet(17,1)=2.3617; zet(17,2)=2.0176
zet(18,1)=2.5796; zet(18,2)=2.2501
zet(19,1)=0.9362; zet(19,2)=0.6914
zet(20,1)=1.2112; zet(20,2)=0.9329
zet(21,1)=1.2870; zet(21,2)=0.9828; zet(21,3)=2.4341
zet(22,1)=1.3416; zet(22,2)=1.0104; zet(22,3)=2.6439
zet(23,1)=1.3570; zet(23,2)=0.9947; zet(23,3)=2.7809
zet(24,1)=1.3804; zet(24,2)=0.9784; zet(24,3)=2.9775
zet(25,1)=1.4761; zet(25,2)=1.0641; zet(25,3)=3.2208
zet(26,1)=1.5465; zet(26,2)=1.1114; zet(26,3)=3.4537
zet(27,1)=1.5650; zet(27,2)=1.1001; zet(27,3)=3.6023
zet(28,1)=1.5532; zet(28,2)=1.0594; zet(28,3)=3.7017
zet(29,1)=1.5791; zet(29,2)=1.0527; zet(29,3)=3.8962
zet(30,1)=1.7778; zet(30,2)=1.2448
zet(31,1)=2.0675; zet(31,2)=1.5073
zet(32,1)=2.2702; zet(32,2)=1.7680
zet(33,1)=2.4546; zet(33,2)=1.9819
zet(34,1)=2.5680; zet(34,2)=2.0548
zet(35,1)=2.7523; zet(35,2)=2.2652
zet(36,1)=2.9299; zet(36,2)=2.4617
zet(37,1)=1.0963; zet(37,2)=0.7990
zet(38,1)=1.3664; zet(38,2)=1.0415
zet(39,1)=1.4613; zet(39,2)=1.1100; zet(39,3)=2.1576
zet(40,1)=1.5393; zet(40,2)=1.1647; zet(40,3)=2.3831
zet(41,1)=1.5926; zet(41,2)=1.1738; zet(41,3)=2.6256
zet(42,1)=1.6579; zet(42,2)=1.2186; zet(42,3)=2.8241
zet(43,1)=1.693;  zet(43,2)=1.249;  zet(43,3)=2.934
zet(44,1)=1.7347; zet(44,2)=1.2514; zet(44,3)=3.1524
zet(45,1)=1.7671; zet(45,2)=1.2623; zet(45,3)=3.3113
zet(46,1)=1.6261; zet(46,2)=1.1221; zet(46,3)=3.0858
zet(47,1)=1.8184; zet(47,2)=1.2719; zet(47,3)=3.6171
zet(48,1)=1.9900; zet(48,2)=1.4596
zet(49,1)=2.4649; zet(49,2)=1.6848
zet(50,1)=2.4041; zet(50,2)=1.9128
zet(51,1)=2.5492; zet(51,2)=2.0781
zet(52,1)=2.6576; zet(52,2)=2.1718
zet(53,1)=2.8080; zet(53,2)=2.3390
zet(54,1)=2.9595; zet(54,2)=2.5074
zet(55,1)=1.1993; zet(55,2)=0.8918
zet(56,1)=1.4519; zet(56,2)=1.1397
zet(72,1)=1.8411; zet(72,2)=1.3822; zet(72,3)=2.7702
zet(73,1)=1.9554; zet(73,2)=1.4857; zet(73,3)=3.0193
zet(74,1)=2.0190; zet(74,2)=1.5296; zet(74,3)=3.1936
zet(75,1)=2.0447; zet(75,2)=1.5276; zet(75,3)=3.3237
zet(76,1)=2.1361; zet(76,2)=1.6102; zet(76,3)=3.5241
zet(77,1)=2.2167; zet(77,2)=1.6814; zet(77,3)=3.7077
zet(78,1)=2.2646; zet(78,2)=1.6759; zet(78,3)=3.8996
zet(79,1)=2.3185; zet(79,2)=1.7126; zet(79,3)=4.0525
zet(80,1)=2.4306; zet(80,2)=1.8672
zet(81,1)=2.5779; zet(81,2)=1.9899
zet(82,1)=2.7241; zet(82,2)=2.1837
zet(83,1)=2.7869; zet(83,2)=2.2146
zet(84,1)=2.9312; zet(84,2)=2.3830
zet(85,1)=3.116 ; zet(85,2)=2.62
zet(86,1)=3.2053; zet(86,2)=2.6866
!
!     JGB: Orbital energies via RO-Hartree-Fock in def2-SV(P) basis
!
ip( 1,1)=  -13.5861
ip( 2,1)=  -24.8753
ip( 3,1)=   -5.2295; ip( 3,2)=    2.4753
ip( 4,1)=   -8.3112; ip( 4,2)=    1.5060
ip( 5,1)=  -13.2273; ip( 5,2)=   -8.5434
ip( 6,1)=  -18.8232; ip( 6,2)=  -11.8678
ip( 7,1)=  -25.1772; ip( 7,2)=  -15.4737
ip( 8,1)=  -33.0875; ip( 8,2)=  -17.1238
ip( 9,1)=  -41.7643; ip( 9,2)=  -19.6799
ip(10,1)=  -51.2186; ip(10,2)=  -22.8274
ip(11,1)=   -4.8784; ip(11,2)=    2.1704
ip(12,1)=   -6.8463; ip(12,2)=    1.4635
ip(13,1)=  -10.5650; ip(13,2)=   -5.7120
ip(14,1)=  -14.5129; ip(14,2)=   -8.0389
ip(15,1)=  -18.7284; ip(15,2)=  -10.5677
ip(16,1)=  -23.6278; ip(16,2)=  -11.7140
ip(17,1)=  -28.8025; ip(17,2)=  -13.4945
ip(18,1)=  -34.2739; ip(18,2)=  -15.6977
ip(19,1)=   -3.9845; ip(19,2)=    1.4229
ip(20,1)=   -5.3104; ip(20,2)=    2.1638
ip(21,1)=   -5.6939; ip(21,2)=    2.7873; ip(21,3)=   -9.3721
ip(22,1)=   -5.9957; ip(22,2)=    3.1853; ip(22,3)=  -11.0538
ip(23,1)=   -6.2649; ip(23,2)=    3.4964; ip(23,3)=  -12.5309
ip(24,1)=   -6.5607; ip(24,2)=    3.7194; ip(24,3)=  -14.4479
ip(25,1)=   -6.7422; ip(25,2)=    4.0168; ip(25,3)=  -15.1746
ip(26,1)=   -6.9814; ip(26,2)=    4.2349; ip(26,3)=  -16.3897
ip(27,1)=   -7.2044; ip(27,2)=    4.4276; ip(27,3)=  -17.5661
ip(28,1)=   -7.4183; ip(28,2)=    4.5822; ip(28,3)=  -18.7092
ip(29,1)=   -7.7010; ip(29,2)=    4.7031; ip(29,3)=  -20.7264
ip(30,1)=   -7.8205; ip(30,2)=    5.1437; ip(30,3)=  -20.9145
ip(31,1)=  -11.4758; ip(31,2)=   -5.6708 
ip(32,1)=  -14.9566; ip(32,2)=   -7.7913
ip(33,1)=  -18.5424; ip(33,2)=  -10.0076
ip(34,1)=  -22.6251; ip(34,2)=  -10.8705
ip(35,1)=  -26.8171; ip(35,2)=  -12.3088
ip(36,1)=  -31.1482; ip(36,2)=  -14.1032
ip(37,1)=   -3.8111; ip(37,2)=    0.8716
ip(38,1)=   -4.9246; ip(38,2)=    0.8197
ip(39,1)=   -5.4885; ip(39,2)=    0.7267; ip(39,3)=   -6.2872
ip(40,1)=   -5.8596; ip(40,2)=    0.7449; ip(40,3)=   -7.9018
ip(41,1)=   -6.1718; ip(41,2)=    0.9082; ip(41,3)=   -9.4017
ip(42,1)=   -6.4442; ip(42,2)=    0.9973; ip(42,3)=  -10.8588
ip(43,1)=   -6.6799; ip(43,2)=    1.0708; ip(43,3)=  -12.3238
ip(44,1)=   -6.9081; ip(44,2)=    1.1741; ip(44,3)=  -13.8110
ip(45,1)=   -7.0715; ip(45,2)=    1.1829; ip(45,3)=  -15.4712
ip(46,1)=   -7.2612; ip(46,2)=    1.1233; ip(46,3)=  -16.9126
ip(47,1)=   -7.4444; ip(47,2)=    1.2598; ip(47,3)=  -18.3876
ip(48,1)=   -7.6402; ip(48,2)=    1.5374; ip(48,3)=  -19.6117
ip(49,1)=  -10.7530; ip(49,2)=   -5.2891
ip(50,1)=  -13.7667; ip(50,2)=   -7.1405
ip(51,1)=  -16.8302; ip(51,2)=   -9.0440
ip(52,1)=  -20.2866; ip(52,2)=   -9.7181
ip(53,1)=  -23.8046; ip(53,2)=  -10.8929
ip(54,1)=  -27.4655; ip(54,2)=  -12.4100
ip(55,1)=   -3.4993; ip(55,2)=    0.7429
ip(56,1)=   -4.4089; ip(56,2)=    0.8326

ip(71,1)=   -5.9489; ip(71,2)=    0.8385; ip(71,3)=   -5.1274
ip(72,1)=   -6.4634; ip(72,2)=    0.9753; ip(72,3)=   -6.5165
ip(73,1)=   -6.8580; ip(73,2)=    1.2406; ip(73,3)=   -7.7975
ip(74,1)=   -7.2050; ip(74,2)=    1.2126; ip(74,3)=   -9.0335
ip(75,1)=   -7.4998; ip(75,2)=    1.4470; ip(75,3)=  -10.2754
ip(76,1)=   -7.7960; ip(76,2)=    1.7780; ip(76,3)=  -11.5291
ip(77,1)=   -8.0900; ip(77,2)=    1.7206; ip(77,3)=  -12.7281
ip(78,1)=   -8.3686; ip(78,2)=    1.6460; ip(78,3)=  -14.0316
ip(79,1)=   -8.6255; ip(79,2)=    1.7822; ip(79,3)=  -15.2250
ip(80,1)=   -8.8865; ip(80,2)=    2.2599; ip(80,3)=  -16.4205
ip(81,1)=  -12.1714; ip(81,2)=   -5.0646
ip(82,1)=  -15.2836; ip(82,2)=   -6.8053
ip(83,1)=  -18.4165; ip(83,2)=   -8.5953
ip(84,1)=  -21.9205; ip(84,2)=   -9.1824
ip(85,1)=  -25.4600; ip(85,2)=  -10.2454
ip(86,1)=  -29.1286; ip(86,2)=  -11.6273

!
!     Hermans' values (up to Z=36)
!
ip(1,1)=-13.598; ip(1,2)=0
ip(2,1)=-24.587
ip(3,1)=-5.392; ip(3,2)=-3.540   
ip(4,1)=-9.323; ip(4,2)=-5.600
ip(5,1)=-14.688; ip(5,2)=-8.298
ip(6,1)=-20.337; ip(6,2)=-11.260
ip(7,1)=-26.685; ip(7,2)=-14.534
ip(8,1)=-28.541; ip(8,2)=-13.618
ip(9,1)=-36.369; ip(9,2)=-17.423
ip(10,1)=-44.924; ip(10,2)=-21.565
ip(11,1)=-5.139; ip(11,2)=-3.091
ip(12,1)=-7.646; ip(12,2)=-4.280
ip(13,1)=-11.839; ip(13,2)=-5.986
ip(14,1)=-17.738; ip(14,2)=-8.152
ip(15,1)=-19.803; ip(15,2)=-10.487
ip(16,1)=-20.941; ip(16,2)=-10.360
ip(17,1)=-25.452; ip(17,2)=-12.968
ip(18,1)=-30.168; ip(18,2)=-15.760
ip(19,1)=-4.341; ip(19,2)=-2.786
ip(20,1)=-6.113; ip(20,2)=-3.744
ip(21,1)=-6.561; ip(21,2)=-3.913; ip(21,3)=-9.450
ip(22,1)=-6.828; ip(22,2)=-3.973; ip(22,3)=-10.495
ip(23,1)=-6.746; ip(23,2)=-3.842; ip(23,3)=-10.370
ip(24,1)=-6.766; ip(24,2)=-3.739; ip(24,3)=-10.642
ip(25,1)=-7.434; ip(25,2)=-4.060; ip(25,3)=-13.017
ip(26,1)=-7.902; ip(26,2)=-4.228; ip(26,3)=-14.805
ip(27,1)=-7.881; ip(27,2)=-4.141; ip(27,3)=-14.821
ip(28,1)=-7.640; ip(28,2)=-3.956; ip(28,3)=-13.820
ip(29,1)=-7.726; ip(29,2)=-3.913; ip(29,3)=-14.100
ip(30,1)=-9.394; ip(30,2)=-4.664
ip(31,1)=-13.234; ip(31,2)=-5.999
ip(32,1)=-16.579; ip(32,2)=-7.899
ip(33,1)=-19.825; ip(33,2)=-9.789
ip(34,1)=-20.658; ip(34,2)=-9.752
ip(35,1)=-24.165; ip(35,2)=-11.814
ip(36,1)=-27.781; ip(36,2)=-14.000

return
end subroutine setZETAandIP
