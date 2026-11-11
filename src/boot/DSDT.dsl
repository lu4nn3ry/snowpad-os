/*
 * Intel ACPI Component Architecture
 * AML/ASL+ Disassembler version 20230628 (64-bit version)
 * Copyright (c) 2000 - 2023 Intel Corporation
 * 
 * Disassembling to symbolic ASL+ operators
 *
 * Disassembly of DSDT.aml, Thu Feb 11 18:37:59 2016
 *
 * Original Table Header:
 *     Signature        "DSDT"
 *     Length           0x00007697 (30359)
 *     Revision         0x01 **** 32-bit table (V1), no 64-bit math support
 *     Checksum         0x96
 *     OEM ID           "00052"
 *     OEM Table ID     "00052000"
 *     OEM Revision     0x00000000 (0)
 *     Compiler ID      "INTL"
 *     Compiler Version 0x20051117 (537202967)
 */
DefinitionBlock ("", "DSDT", 1, "00052", "00052000", 0x00000000)
{
    Scope (_PR)
    {
        Processor (P001, 0x01, 0x00000810, 0x06){}
        Alias (P001, CPU1)
    }

    Scope (_PR)
    {
        Processor (P002, 0x02, 0x00000810, 0x06){}
        Alias (P002, CPU2)
    }

    Name (DP80, 0x80)
    Name (DP90, 0x90)
    Name (ECCM, 0x6C)
    Name (APIC, One)
    Name (PMBS, 0x0800)
    Name (PMLN, 0x80)
    Name (GPBS, 0x0480)
    Name (GPLN, 0x40)
    Name (SMBL, Zero)
    Name (PM30, 0x0830)
    Name (SUSW, 0xFF)
    Name (SMIO, 0xB2)
    Name (SMIP, 0xB2)
    Name (TOBS, 0x0860)
    Name (SUCC, One)
    Name (NVLD, 0x02)
    Name (CRIT, 0x04)
    Name (NCRT, 0x06)
    Name (LIDS, One)
    Name (CHST, 0x0D)
    Name (DVMT, 0x04)
    Name (PCIB, 0xE0000000)
    Name (PCIL, 0x10000000)
    Name (PEHP, One)
    Name (SHPC, Zero)
    Name (PEPM, One)
    Name (PEER, One)
    Name (PECS, One)
    Name (SMBS, 0x0400)
    OperationRegion (BIOS, SystemMemory, 0x7F6AE064, 0xFF)
    Field (BIOS, ByteAcc, NoLock, Preserve)
    {
        SS1,    1, 
        SS2,    1, 
        SS3,    1, 
        SS4,    1, 
        Offset (0x01), 
        IOST,   16, 
        TOPM,   32, 
        ROMS,   32, 
        MG1B,   32, 
        MG1L,   32, 
        MG2B,   32, 
        MG2L,   32, 
        Offset (0x1C), 
        DMAX,   8, 
        HPTA,   32, 
        CPB0,   32, 
        CPB1,   32, 
        CPB2,   32, 
        CPB3,   32, 
        ASSB,   8, 
        AOTB,   8, 
        AAXB,   32, 
        SMIF,   8, 
        DTSE,   8, 
        DTS1,   8, 
        DTS2,   8, 
        MPEN,   8, 
        TPMF,   8, 
        MG3B,   32, 
        MG3L,   32, 
        MH1B,   32, 
        MH1L,   32, 
        OSTP,   8, 
        OSTY,   8, 
        PMOD,   8
    }

    Method (RRIO, 4, NotSerialized)
    {
        Debug = "RRIO"
    }

    Method (RDMA, 3, NotSerialized)
    {
        Debug = "rDMA"
    }

    Name (PICM, Zero)
    Method (_PIC, 1, NotSerialized)  // _PIC: Interrupt Model
    {
        If (Arg0)
        {
            DBG8 = 0xAA
        }
        Else
        {
            DBG8 = 0xAC
        }

        PICM = Arg0
    }

    Name (OSVR, Ones)
    Method (OSFL, 0, NotSerialized)
    {
        If ((OSVR != Ones))
        {
            Return (OSVR) /* \OSVR */
        }

        Name (TTT0, Zero)
        TTT0 = OSYS ()
        If ((TTT0 == One))
        {
            OSVR = 0x03
        }
        ElseIf ((TTT0 == 0x10))
        {
            OSVR = One
        }
        ElseIf ((TTT0 == 0x11))
        {
            OSVR = 0x02
        }
        ElseIf ((TTT0 == 0x12))
        {
            OSVR = 0x04
        }
        ElseIf ((TTT0 == 0x13))
        {
            OSVR = Zero
        }
        ElseIf ((TTT0 == 0x14))
        {
            OSVR = Zero
        }
        ElseIf ((TTT0 == 0x15))
        {
            OSVR = Zero
        }

        Return (OSVR) /* \OSVR */
    }

    Method (MCTH, 2, NotSerialized)
    {
        If ((SizeOf (Arg0) < SizeOf (Arg1)))
        {
            Return (Zero)
        }

        Local0 = (SizeOf (Arg0) + One)
        Name (BUF0, Buffer (Local0){})
        Name (BUF1, Buffer (Local0){})
        BUF0 = Arg0
        BUF1 = Arg1
        While (Local0)
        {
            Local0--
            If ((DerefOf (BUF0 [Local0]) != DerefOf (BUF1 [Local0]
                )))
            {
                Return (Zero)
            }
        }

        Return (One)
    }

    Name (PRWP, Package (0x02)
    {
        Zero, 
        Zero
    })
    Method (GPRW, 2, NotSerialized)
    {
        PRWP [Zero] = Arg0
        Local0 = (SS1 << One)
        Local0 |= (SS2 << 0x02)
        Local0 |= (SS3 << 0x03)
        Local0 |= (SS4 << 0x04)
        If (((One << Arg1) & Local0))
        {
            PRWP [One] = Arg1
        }
        Else
        {
            Local0 >>= One
            If (((OSFL () == One) || (OSFL () == 0x02)))
            {
                FindSetLeftBit (Local0, PRWP [One])
            }
            Else
            {
                FindSetRightBit (Local0, PRWP [One])
            }
        }

        Return (PRWP) /* \PRWP */
    }

    Name (WAKP, Package (0x02)
    {
        Zero, 
        Zero
    })
    OperationRegion (DEB0, SystemIO, DP80, One)
    Field (DEB0, ByteAcc, NoLock, Preserve)
    {
        DBG8,   8
    }

    OperationRegion (DEB1, SystemIO, DP90, 0x02)
    Field (DEB1, WordAcc, NoLock, Preserve)
    {
        DBG9,   16
    }

    OperationRegion (IO6C, SystemIO, ECCM, One)
    Field (IO6C, ByteAcc, NoLock, Preserve)
    {
        EC6C,   8
    }

    Method (OSYS, 0, NotSerialized)
    {
        Local0 = 0x10
        If (CondRefOf (_OSI, Local1))
        {
            If (_OSI ("Windows 2000"))
            {
                Local0 = 0x12
            }

            If (_OSI ("Windows 2001"))
            {
                Local0 = 0x13
            }

            If (_OSI ("Windows 2001 SP1"))
            {
                Local0 = 0x13
            }

            If (_OSI ("Windows 2001 SP2"))
            {
                Local0 = 0x13
            }

            If (_OSI ("Windows 2001.1"))
            {
                Local0 = 0x14
            }

            If (_OSI ("Windows 2001.1 SP1"))
            {
                Local0 = 0x14
            }

            If (_OSI ("Windows 2006"))
            {
                Local0 = 0x15
            }
        }
        ElseIf (MCTH (_OS, "Microsoft Windows NT"))
        {
            Local0 = 0x12
        }
        Else
        {
            If (MCTH (_OS, "Microsoft WindowsME: Millennium Edition"))
            {
                Local0 = 0x11
            }

            If (MCTH (_OS, "Linux"))
            {
                Local0 = One
            }
        }

        Return (Local0)
    }

    Scope (_SB)
    {
        Name (PR00, Package (0x0E)
        {
            Package (0x04)
            {
                0x001EFFFF, 
                Zero, 
                LNKB, 
                Zero
            }, 

            Package (0x04)
            {
                0x001EFFFF, 
                One, 
                LNKE, 
                Zero
            }, 

            Package (0x04)
            {
                0x001FFFFF, 
                Zero, 
                LNKC, 
                Zero
            }, 

            Package (0x04)
            {
                0x001FFFFF, 
                One, 
                LNKD, 
                Zero
            }, 

            Package (0x04)
            {
                0x001BFFFF, 
                Zero, 
                LNKA, 
                Zero
            }, 

            Package (0x04)
            {
                0x001CFFFF, 
                Zero, 
                LNKA, 
                Zero
            }, 

            Package (0x04)
            {
                0x001CFFFF, 
                One, 
                LNKB, 
                Zero
            }, 

            Package (0x04)
            {
                0x001CFFFF, 
                0x02, 
                LNKC, 
                Zero
            }, 

            Package (0x04)
            {
                0x001CFFFF, 
                0x03, 
                LNKD, 
                Zero
            }, 

            Package (0x04)
            {
                0x0002FFFF, 
                Zero, 
                LNKA, 
                Zero
            }, 

            Package (0x04)
            {
                0x001DFFFF, 
                Zero, 
                LNKH, 
                Zero
            }, 

            Package (0x04)
            {
                0x001DFFFF, 
                One, 
                LNKD, 
                Zero
            }, 

            Package (0x04)
            {
                0x001DFFFF, 
                0x02, 
                LNKC, 
                Zero
            }, 

            Package (0x04)
            {
                0x001DFFFF, 
                0x03, 
                LNKA, 
                Zero
            }
        })
        Name (AR00, Package (0x0E)
        {
            Package (0x04)
            {
                0x001EFFFF, 
                Zero, 
                Zero, 
                0x11
            }, 

            Package (0x04)
            {
                0x001EFFFF, 
                One, 
                Zero, 
                0x14
            }, 

            Package (0x04)
            {
                0x001FFFFF, 
                Zero, 
                Zero, 
                0x12
            }, 

            Package (0x04)
            {
                0x001FFFFF, 
                One, 
                Zero, 
                0x13
            }, 

            Package (0x04)
            {
                0x001BFFFF, 
                Zero, 
                Zero, 
                0x10
            }, 

            Package (0x04)
            {
                0x001CFFFF, 
                Zero, 
                Zero, 
                0x10
            }, 

            Package (0x04)
            {
                0x001CFFFF, 
                One, 
                Zero, 
                0x11
            }, 

            Package (0x04)
            {
                0x001CFFFF, 
                0x02, 
                Zero, 
                0x12
            }, 

            Package (0x04)
            {
                0x001CFFFF, 
                0x03, 
                Zero, 
                0x13
            }, 

            Package (0x04)
            {
                0x0002FFFF, 
                Zero, 
                Zero, 
                0x10
            }, 

            Package (0x04)
            {
                0x001DFFFF, 
                Zero, 
                Zero, 
                0x17
            }, 

            Package (0x04)
            {
                0x001DFFFF, 
                One, 
                Zero, 
                0x13
            }, 

            Package (0x04)
            {
                0x001DFFFF, 
                0x02, 
                Zero, 
                0x12
            }, 

            Package (0x04)
            {
                0x001DFFFF, 
                0x03, 
                Zero, 
                0x10
            }
        })
        Name (PR01, Package (0x08)
        {
            Package (0x04)
            {
                0xFFFF, 
                Zero, 
                LNKA, 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                One, 
                LNKB, 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x02, 
                LNKC, 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x03, 
                LNKD, 
                Zero
            }, 

            Package (0x04)
            {
                0x0001FFFF, 
                Zero, 
                LNKB, 
                Zero
            }, 

            Package (0x04)
            {
                0x0001FFFF, 
                One, 
                LNKC, 
                Zero
            }, 

            Package (0x04)
            {
                0x0001FFFF, 
                0x02, 
                LNKD, 
                Zero
            }, 

            Package (0x04)
            {
                0x0001FFFF, 
                0x03, 
                LNKA, 
                Zero
            }
        })
        Name (AR01, Package (0x08)
        {
            Package (0x04)
            {
                0xFFFF, 
                Zero, 
                Zero, 
                0x10
            }, 

            Package (0x04)
            {
                0xFFFF, 
                One, 
                Zero, 
                0x11
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x02, 
                Zero, 
                0x12
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x03, 
                Zero, 
                0x13
            }, 

            Package (0x04)
            {
                0x0001FFFF, 
                Zero, 
                Zero, 
                0x11
            }, 

            Package (0x04)
            {
                0x0001FFFF, 
                One, 
                Zero, 
                0x12
            }, 

            Package (0x04)
            {
                0x0001FFFF, 
                0x02, 
                Zero, 
                0x13
            }, 

            Package (0x04)
            {
                0x0001FFFF, 
                0x03, 
                Zero, 
                0x10
            }
        })
        Name (PR04, Package (0x04)
        {
            Package (0x04)
            {
                0xFFFF, 
                Zero, 
                LNKA, 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                One, 
                LNKB, 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x02, 
                LNKC, 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x03, 
                LNKD, 
                Zero
            }
        })
        Name (AR04, Package (0x04)
        {
            Package (0x04)
            {
                0xFFFF, 
                Zero, 
                Zero, 
                0x10
            }, 

            Package (0x04)
            {
                0xFFFF, 
                One, 
                Zero, 
                0x11
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x02, 
                Zero, 
                0x12
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x03, 
                Zero, 
                0x13
            }
        })
        Name (PR05, Package (0x04)
        {
            Package (0x04)
            {
                0xFFFF, 
                Zero, 
                LNKB, 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                One, 
                LNKC, 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x02, 
                LNKD, 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x03, 
                LNKA, 
                Zero
            }
        })
        Name (AR05, Package (0x04)
        {
            Package (0x04)
            {
                0xFFFF, 
                Zero, 
                Zero, 
                0x11
            }, 

            Package (0x04)
            {
                0xFFFF, 
                One, 
                Zero, 
                0x12
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x02, 
                Zero, 
                0x13
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x03, 
                Zero, 
                0x10
            }
        })
        Name (PR06, Package (0x04)
        {
            Package (0x04)
            {
                0xFFFF, 
                Zero, 
                LNKC, 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                One, 
                LNKD, 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x02, 
                LNKA, 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x03, 
                LNKB, 
                Zero
            }
        })
        Name (AR06, Package (0x04)
        {
            Package (0x04)
            {
                0xFFFF, 
                Zero, 
                Zero, 
                0x12
            }, 

            Package (0x04)
            {
                0xFFFF, 
                One, 
                Zero, 
                0x13
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x02, 
                Zero, 
                0x10
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x03, 
                Zero, 
                0x11
            }
        })
        Name (PR07, Package (0x04)
        {
            Package (0x04)
            {
                0xFFFF, 
                Zero, 
                LNKD, 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                One, 
                LNKA, 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x02, 
                LNKB, 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x03, 
                LNKC, 
                Zero
            }
        })
        Name (AR07, Package (0x04)
        {
            Package (0x04)
            {
                0xFFFF, 
                Zero, 
                Zero, 
                0x13
            }, 

            Package (0x04)
            {
                0xFFFF, 
                One, 
                Zero, 
                0x10
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x02, 
                Zero, 
                0x11
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x03, 
                Zero, 
                0x12
            }
        })
        Name (PR08, Package (0x04)
        {
            Package (0x04)
            {
                0xFFFF, 
                Zero, 
                LNKA, 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                One, 
                LNKB, 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x02, 
                LNKC, 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x03, 
                LNKD, 
                Zero
            }
        })
        Name (AR08, Package (0x04)
        {
            Package (0x04)
            {
                0xFFFF, 
                Zero, 
                Zero, 
                0x10
            }, 

            Package (0x04)
            {
                0xFFFF, 
                One, 
                Zero, 
                0x11
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x02, 
                Zero, 
                0x12
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x03, 
                Zero, 
                0x13
            }
        })
        Name (PR09, Package (0x04)
        {
            Package (0x04)
            {
                0xFFFF, 
                Zero, 
                LNKB, 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                One, 
                LNKC, 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x02, 
                LNKD, 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x03, 
                LNKA, 
                Zero
            }
        })
        Name (AR09, Package (0x04)
        {
            Package (0x04)
            {
                0xFFFF, 
                Zero, 
                Zero, 
                0x11
            }, 

            Package (0x04)
            {
                0xFFFF, 
                One, 
                Zero, 
                0x12
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x02, 
                Zero, 
                0x13
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x03, 
                Zero, 
                0x10
            }
        })
        Name (PRSA, ResourceTemplate ()
        {
            IRQ (Level, ActiveLow, Shared, )
                {3,4,5,7,10,11,12,14,15}
        })
        Alias (PRSA, PRSB)
        Alias (PRSA, PRSC)
        Alias (PRSA, PRSD)
        Alias (PRSA, PRSE)
        Alias (PRSA, PRSF)
        Alias (PRSA, PRSG)
        Alias (PRSA, PRSH)
        Device (PCI0)
        {
            Name (_HID, EisaId ("PNP0A08") /* PCI Express Bus */)  // _HID: Hardware ID
            Name (_ADR, Zero)  // _ADR: Address
            Method (^BN00, 0, NotSerialized)
            {
                Return (Zero)
            }

            Method (_BBN, 0, NotSerialized)  // _BBN: BIOS Bus Number
            {
                Return (BN00 ())
            }

            Name (_UID, Zero)  // _UID: Unique ID
            Method (_PRT, 0, NotSerialized)  // _PRT: PCI Routing Table
            {
                If (PICM)
                {
                    Return (AR00) /* \_SB_.AR00 */
                }

                Return (PR00) /* \_SB_.PR00 */
            }

            Method (_S3D, 0, NotSerialized)  // _S3D: S3 Device State
            {
                If (((OSFL () == One) || (OSFL () == 0x02)))
                {
                    Return (0x02)
                }
                Else
                {
                    Return (0x03)
                }
            }

            Name (_CID, EisaId ("PNP0A03") /* PCI Bus */)  // _CID: Compatible ID
            Device (MCH)
            {
                Name (_HID, EisaId ("PNP0C01") /* System Board */)  // _HID: Hardware ID
                Name (_UID, 0x0A)  // _UID: Unique ID
                Name (_CRS, ResourceTemplate ()  // _CRS: Current Resource Settings
                {
                    Memory32Fixed (ReadWrite,
                        0xFED14000,         // Address Base
                        0x00006000,         // Address Length
                        )
                    Memory32Fixed (ReadWrite,
                        0xFED90000,         // Address Base
                        0x00004000,         // Address Length
                        )
                })
            }

            Method (NPTS, 1, NotSerialized)
            {
            }

            Method (NWAK, 1, NotSerialized)
            {
            }

            Device (P0P1)
            {
                Name (_ADR, 0x001E0000)  // _ADR: Address
                Method (_PRW, 0, NotSerialized)  // _PRW: Power Resources for Wake
                {
                    Return (GPRW (0x0B, 0x04))
                }

                Method (_PRT, 0, NotSerialized)  // _PRT: PCI Routing Table
                {
                    If (PICM)
                    {
                        Return (AR01) /* \_SB_.AR01 */
                    }

                    Return (PR01) /* \_SB_.PR01 */
                }
            }

            Device (SBRG)
            {
                Name (_ADR, 0x001F0000)  // _ADR: Address
                Device (IELK)
                {
                    Name (_HID, "AWY0001")  // _HID: Hardware ID
                    OperationRegion (RXA0, PCI_Config, 0xA0, 0x20)
                    Field (RXA0, ByteAcc, NoLock, Preserve)
                    {
                            ,   9, 
                        PBLV,   1, 
                        Offset (0x10), 
                            ,   1, 
                        PBMS,   1, 
                            ,   1, 
                        PMCS,   1, 
                        ECNS,   1, 
                        Offset (0x11), 
                        ECT1,   16, 
                        ELEN,   1, 
                        Offset (0x14)
                    }

                    Method (\_GPE._L0A, 0, NotSerialized)  // _Lxx: Level-Triggered GPE, xx=0x00-0xFF
                    {
                        Notify (\_SB.PCI0.SBRG.IELK, 0x81) // Information Change
                        \_SB.PCI0.SBRG.IELK.PMCS = One
                    }

                    Method (_STA, 0, NotSerialized)  // _STA: Status
                    {
                        If (ELEN)
                        {
                            Return (0x0F)
                        }
                        Else
                        {
                            Return (Zero)
                        }
                    }

                    Method (SMOD, 1, NotSerialized)
                    {
                    }

                    Method (GPBS, 0, NotSerialized)
                    {
                        Return ((PBLV ^ One))
                    }
                }

                Method (SPTS, 1, NotSerialized)
                {
                    PS1S = One
                    PS1E = One
                    SLPS = One
                }

                Method (SWAK, 1, NotSerialized)
                {
                    SLPS = Zero
                    PS1E = Zero
                    If ((Arg0 == 0x04))
                    {
                        EC6C = 0xC7
                    }

                    If (((Arg0 == One) && RTCS)){}
                    ElseIf (((Arg0 == 0x03) && BRTC)){}
                    Else
                    {
                        Notify (PWRB, 0x02) // Device Wake
                    }
                }

                OperationRegion (APMP, SystemIO, SMIO, 0x02)
                Field (APMP, ByteAcc, NoLock, Preserve)
                {
                    APMC,   8, 
                    APMS,   8
                }

                Field (APMP, ByteAcc, NoLock, Preserve)
                {
                    Offset (0x01), 
                        ,   1, 
                    BRTC,   1
                }

                OperationRegion (PMS0, SystemIO, PMBS, 0x04)
                Field (PMS0, ByteAcc, NoLock, Preserve)
                {
                        ,   10, 
                    RTCS,   1, 
                        ,   4, 
                    WAKS,   1, 
                    Offset (0x03), 
                    PWBT,   1, 
                    Offset (0x04)
                }

                OperationRegion (SMIE, SystemIO, PM30, 0x08)
                Field (SMIE, ByteAcc, NoLock, Preserve)
                {
                        ,   4, 
                    PS1E,   1, 
                        ,   31, 
                    PS1S,   1, 
                    Offset (0x08)
                }

                Scope (\_SB)
                {
                    Name (SLPS, Zero)
                }

                Device (PIC)
                {
                    Name (_HID, EisaId ("PNP0000") /* 8259-compatible Programmable Interrupt Controller */)  // _HID: Hardware ID
                    Name (_CRS, ResourceTemplate ()  // _CRS: Current Resource Settings
                    {
                        IO (Decode16,
                            0x0020,             // Range Minimum
                            0x0020,             // Range Maximum
                            0x00,               // Alignment
                            0x02,               // Length
                            )
                        IO (Decode16,
                            0x00A0,             // Range Minimum
                            0x00A0,             // Range Maximum
                            0x00,               // Alignment
                            0x02,               // Length
                            )
                        IRQNoFlags ()
                            {2}
                    })
                }

                Device (DMAD)
                {
                    Name (_HID, EisaId ("PNP0200") /* PC-class DMA Controller */)  // _HID: Hardware ID
                    Name (_CRS, ResourceTemplate ()  // _CRS: Current Resource Settings
                    {
                        DMA (Compatibility, BusMaster, Transfer8, )
                            {4}
                        IO (Decode16,
                            0x0000,             // Range Minimum
                            0x0000,             // Range Maximum
                            0x00,               // Alignment
                            0x10,               // Length
                            )
                        IO (Decode16,
                            0x0081,             // Range Minimum
                            0x0081,             // Range Maximum
                            0x00,               // Alignment
                            0x03,               // Length
                            )
                        IO (Decode16,
                            0x0087,             // Range Minimum
                            0x0087,             // Range Maximum
                            0x00,               // Alignment
                            0x01,               // Length
                            )
                        IO (Decode16,
                            0x0089,             // Range Minimum
                            0x0089,             // Range Maximum
                            0x00,               // Alignment
                            0x03,               // Length
                            )
                        IO (Decode16,
                            0x008F,             // Range Minimum
                            0x008F,             // Range Maximum
                            0x00,               // Alignment
                            0x01,               // Length
                            )
                        IO (Decode16,
                            0x00C0,             // Range Minimum
                            0x00C0,             // Range Maximum
                            0x00,               // Alignment
                            0x20,               // Length
                            )
                    })
                }

                Device (TMR)
                {
                    Name (_HID, EisaId ("PNP0100") /* PC-class System Timer */)  // _HID: Hardware ID
                    Name (_CRS, ResourceTemplate ()  // _CRS: Current Resource Settings
                    {
                        IO (Decode16,
                            0x0040,             // Range Minimum
                            0x0040,             // Range Maximum
                            0x00,               // Alignment
                            0x04,               // Length
                            )
                        IRQNoFlags ()
                            {0}
                    })
                }

                Device (RTC0)
                {
                    Name (_HID, EisaId ("PNP0B00") /* AT Real-Time Clock */)  // _HID: Hardware ID
                    Name (_CRS, ResourceTemplate ()  // _CRS: Current Resource Settings
                    {
                        IO (Decode16,
                            0x0070,             // Range Minimum
                            0x0070,             // Range Maximum
                            0x00,               // Alignment
                            0x02,               // Length
                            )
                        IRQNoFlags ()
                            {8}
                    })
                }

                Device (PS2K)
                {
                    Name (_HID, EisaId ("PNP0303") /* IBM Enhanced Keyboard (101/102-key, PS/2 Mouse) */)  // _HID: Hardware ID
                    Name (_CID, EisaId ("PNP030B"))  // _CID: Compatible ID
                    Method (_STA, 0, NotSerialized)  // _STA: Status
                    {
                        Local0 = (One << 0x0A)
                        If ((IOST & Local0))
                        {
                            Return (0x0F)
                        }

                        Return (Zero)
                    }

                    Name (_CRS, ResourceTemplate ()  // _CRS: Current Resource Settings
                    {
                        IO (Decode16,
                            0x0060,             // Range Minimum
                            0x0060,             // Range Maximum
                            0x00,               // Alignment
                            0x01,               // Length
                            )
                        IO (Decode16,
                            0x0064,             // Range Minimum
                            0x0064,             // Range Maximum
                            0x00,               // Alignment
                            0x01,               // Length
                            )
                        IRQNoFlags ()
                            {1}
                    })
                }

                Device (PS2M)
                {
                    Name (_HID, EisaId ("PNP0F03") /* Microsoft PS/2-style Mouse */)  // _HID: Hardware ID
                    Name (_CID, EisaId ("PNP0F13") /* PS/2 Mouse */)  // _CID: Compatible ID
                    Method (_STA, 0, NotSerialized)  // _STA: Status
                    {
                        Local0 = (One << 0x0C)
                        If ((IOST & Local0))
                        {
                            Return (0x0F)
                        }

                        Return (Zero)
                    }

                    Name (M2R0, ResourceTemplate ()
                    {
                        IRQNoFlags ()
                            {12}
                    })
                    Name (M2R1, ResourceTemplate ()
                    {
                        FixedIO (
                            0x0060,             // Address
                            0x01,               // Length
                            )
                        FixedIO (
                            0x0064,             // Address
                            0x01,               // Length
                            )
                        IRQNoFlags ()
                            {12}
                    })
                    Method (_CRS, 0, NotSerialized)  // _CRS: Current Resource Settings
                    {
                        Local0 = (One << 0x0A)
                        If ((IOST & Local0))
                        {
                            Return (M2R0) /* \_SB_.PCI0.SBRG.PS2M.M2R0 */
                        }
                        Else
                        {
                            Return (M2R1) /* \_SB_.PCI0.SBRG.PS2M.M2R1 */
                        }
                    }
                }

                Device (SPKR)
                {
                    Name (_HID, EisaId ("PNP0800") /* Microsoft Sound System Compatible Device */)  // _HID: Hardware ID
                    Name (_CRS, ResourceTemplate ()  // _CRS: Current Resource Settings
                    {
                        IO (Decode16,
                            0x0061,             // Range Minimum
                            0x0061,             // Range Maximum
                            0x00,               // Alignment
                            0x01,               // Length
                            )
                    })
                }

                Device (COPR)
                {
                    Name (_HID, EisaId ("PNP0C04") /* x87-compatible Floating Point Processing Unit */)  // _HID: Hardware ID
                    Name (_CRS, ResourceTemplate ()  // _CRS: Current Resource Settings
                    {
                        IO (Decode16,
                            0x00F0,             // Range Minimum
                            0x00F0,             // Range Maximum
                            0x00,               // Alignment
                            0x10,               // Length
                            )
                        IRQNoFlags ()
                            {13}
                    })
                }

                Device (RMSC)
                {
                    Name (_HID, EisaId ("PNP0C02") /* PNP Motherboard Resources */)  // _HID: Hardware ID
                    Name (_UID, 0x10)  // _UID: Unique ID
                    Name (CRS, ResourceTemplate ()
                    {
                        IO (Decode16,
                            0x0010,             // Range Minimum
                            0x0010,             // Range Maximum
                            0x00,               // Alignment
                            0x10,               // Length
                            )
                        IO (Decode16,
                            0x0022,             // Range Minimum
                            0x0022,             // Range Maximum
                            0x00,               // Alignment
                            0x1E,               // Length
                            )
                        IO (Decode16,
                            0x0044,             // Range Minimum
                            0x0044,             // Range Maximum
                            0x00,               // Alignment
                            0x1C,               // Length
                            )
                        IO (Decode16,
                            0x0062,             // Range Minimum
                            0x0062,             // Range Maximum
                            0x00,               // Alignment
                            0x02,               // Length
                            )
                        IO (Decode16,
                            0x0065,             // Range Minimum
                            0x0065,             // Range Maximum
                            0x00,               // Alignment
                            0x0B,               // Length
                            )
                        IO (Decode16,
                            0x0072,             // Range Minimum
                            0x0072,             // Range Maximum
                            0x00,               // Alignment
                            0x0E,               // Length
                            )
                        IO (Decode16,
                            0x0080,             // Range Minimum
                            0x0080,             // Range Maximum
                            0x00,               // Alignment
                            0x01,               // Length
                            )
                        IO (Decode16,
                            0x0084,             // Range Minimum
                            0x0084,             // Range Maximum
                            0x00,               // Alignment
                            0x03,               // Length
                            )
                        IO (Decode16,
                            0x0088,             // Range Minimum
                            0x0088,             // Range Maximum
                            0x00,               // Alignment
                            0x01,               // Length
                            )
                        IO (Decode16,
                            0x008C,             // Range Minimum
                            0x008C,             // Range Maximum
                            0x00,               // Alignment
                            0x03,               // Length
                            )
                        IO (Decode16,
                            0x0090,             // Range Minimum
                            0x0090,             // Range Maximum
                            0x00,               // Alignment
                            0x10,               // Length
                            )
                        IO (Decode16,
                            0x00A2,             // Range Minimum
                            0x00A2,             // Range Maximum
                            0x00,               // Alignment
                            0x1E,               // Length
                            )
                        IO (Decode16,
                            0x00E0,             // Range Minimum
                            0x00E0,             // Range Maximum
                            0x00,               // Alignment
                            0x10,               // Length
                            )
                        IO (Decode16,
                            0x04D0,             // Range Minimum
                            0x04D0,             // Range Maximum
                            0x00,               // Alignment
                            0x02,               // Length
                            )
                        IO (Decode16,
                            0x0000,             // Range Minimum
                            0x0000,             // Range Maximum
                            0x00,               // Alignment
                            0x00,               // Length
                            _Y00)
                        IO (Decode16,
                            0x0000,             // Range Minimum
                            0x0000,             // Range Maximum
                            0x00,               // Alignment
                            0x00,               // Length
                            _Y01)
                        IO (Decode16,
                            0x0000,             // Range Minimum
                            0x0000,             // Range Maximum
                            0x00,               // Alignment
                            0x00,               // Length
                            _Y02)
                        Memory32Fixed (ReadWrite,
                            0xFED1C000,         // Address Base
                            0x00004000,         // Address Length
                            )
                        Memory32Fixed (ReadWrite,
                            0xFED20000,         // Address Base
                            0x00070000,         // Address Length
                            )
                    })
                    Method (_CRS, 0, NotSerialized)  // _CRS: Current Resource Settings
                    {
                        CreateWordField (CRS, \_SB.PCI0.SBRG.RMSC._Y00._MIN, GP00)  // _MIN: Minimum Base Address
                        CreateWordField (CRS, \_SB.PCI0.SBRG.RMSC._Y00._MAX, GP01)  // _MAX: Maximum Base Address
                        CreateByteField (CRS, \_SB.PCI0.SBRG.RMSC._Y00._LEN, GP0L)  // _LEN: Length
                        GP00 = PMBS /* \PMBS */
                        GP01 = PMBS /* \PMBS */
                        GP0L = PMLN /* \PMLN */
                        If (SMBS)
                        {
                            CreateWordField (CRS, \_SB.PCI0.SBRG.RMSC._Y01._MIN, GP10)  // _MIN: Minimum Base Address
                            CreateWordField (CRS, \_SB.PCI0.SBRG.RMSC._Y01._MAX, GP11)  // _MAX: Maximum Base Address
                            CreateByteField (CRS, \_SB.PCI0.SBRG.RMSC._Y01._LEN, GP1L)  // _LEN: Length
                            GP10 = SMBS /* \SMBS */
                            GP11 = SMBS /* \SMBS */
                            GP1L = SMBL /* \SMBL */
                        }

                        If (GPBS)
                        {
                            CreateWordField (CRS, \_SB.PCI0.SBRG.RMSC._Y02._MIN, GP20)  // _MIN: Minimum Base Address
                            CreateWordField (CRS, \_SB.PCI0.SBRG.RMSC._Y02._MAX, GP21)  // _MAX: Maximum Base Address
                            CreateByteField (CRS, \_SB.PCI0.SBRG.RMSC._Y02._LEN, GP2L)  // _LEN: Length
                            GP20 = GPBS /* \GPBS */
                            GP21 = GPBS /* \GPBS */
                            GP2L = GPLN /* \GPLN */
                        }

                        Return (CRS) /* \_SB_.PCI0.SBRG.RMSC.CRS_ */
                    }
                }

                Device (HPET)
                {
                    Name (_HID, EisaId ("PNP0103") /* HPET System Timer */)  // _HID: Hardware ID
                    Name (CRS, ResourceTemplate ()
                    {
                        Memory32Fixed (ReadOnly,
                            0xFED00000,         // Address Base
                            0x00000400,         // Address Length
                            _Y03)
                    })
                    OperationRegion (^LPCR, SystemMemory, 0xFED1F404, 0x04)
                    Field (LPCR, AnyAcc, NoLock, Preserve)
                    {
                        HPTS,   2, 
                            ,   5, 
                        HPTE,   1, 
                        Offset (0x04)
                    }

                    Method (_STA, 0, NotSerialized)  // _STA: Status
                    {
                        If ((OSFL () == Zero))
                        {
                            If (HPTE)
                            {
                                Return (0x0F)
                            }
                        }
                        ElseIf (HPTE)
                        {
                            Return (0x0B)
                        }

                        Return (Zero)
                    }

                    Method (_CRS, 0, NotSerialized)  // _CRS: Current Resource Settings
                    {
                        CreateDWordField (CRS, \_SB.PCI0.SBRG.HPET._Y03._BAS, HPT)  // _BAS: Base Address
                        Local0 = (HPTS * 0x1000)
                        HPT = (Local0 + 0xFED00000)
                        Return (CRS) /* \_SB_.PCI0.SBRG.HPET.CRS_ */
                    }
                }

                OperationRegion (RX80, PCI_Config, Zero, 0xFF)
                Field (RX80, ByteAcc, NoLock, Preserve)
                {
                    Offset (0x80), 
                    LPCD,   16, 
                    LPCE,   16
                }

                Name (DBPT, Package (0x04)
                {
                    Package (0x08)
                    {
                        0x03F8, 
                        0x02F8, 
                        0x0220, 
                        0x0228, 
                        0x0238, 
                        0x02E8, 
                        0x0338, 
                        0x03E8
                    }, 

                    Package (0x08)
                    {
                        0x03F8, 
                        0x02F8, 
                        0x0220, 
                        0x0228, 
                        0x0238, 
                        0x02E8, 
                        0x0338, 
                        0x03E8
                    }, 

                    Package (0x03)
                    {
                        0x0378, 
                        0x0278, 
                        0x03BC
                    }, 

                    Package (0x02)
                    {
                        0x03F0, 
                        0x0370
                    }
                })
                Name (DDLT, Package (0x04)
                {
                    Package (0x02)
                    {
                        Zero, 
                        0xFFF8
                    }, 

                    Package (0x02)
                    {
                        0x04, 
                        0xFF8F
                    }, 

                    Package (0x02)
                    {
                        0x08, 
                        0xFCFF
                    }, 

                    Package (0x02)
                    {
                        0x0C, 
                        0xEFFF
                    }
                })
                Method (RRIO, 4, NotSerialized)
                {
                    If (((Arg0 <= 0x03) && (Arg0 >= Zero)))
                    {
                        Local0 = Match (DerefOf (DBPT [Arg0]), MEQ, Arg2, MTR, Zero, 
                            Zero)
                        If ((Local0 != Ones))
                        {
                            Local1 = DerefOf (DerefOf (DDLT [Arg0]) [Zero])
                            Local2 = DerefOf (DerefOf (DDLT [Arg0]) [One])
                            Local0 <<= Local1
                            LPCD &= Local2
                            LPCD |= Local0
                            WX82 (Arg0, Arg1)
                        }
                    }

                    If ((Arg0 == 0x08))
                    {
                        If ((Arg2 == 0x0200))
                        {
                            WX82 (0x08, Arg0)
                        }
                        ElseIf ((Arg2 == 0x0208))
                        {
                            WX82 (0x09, Arg0)
                        }
                    }

                    If (((Arg0 <= 0x0D) && (Arg0 >= 0x0A)))
                    {
                        WX82 (Arg0, Arg1)
                    }
                }

                Method (WX82, 2, NotSerialized)
                {
                    Local0 = (One << Arg0)
                    If (Arg1)
                    {
                        LPCE |= Local0
                    }
                    Else
                    {
                        Local0 = ~Local0
                        LPCE &= Local0
                    }
                }

                Method (RDMA, 3, NotSerialized)
                {
                }

                Method (SCMD, 4, NotSerialized)
                {
                    OperationRegion (SMRG, SystemIO, SMBS, 0x10)
                    Field (SMRG, ByteAcc, NoLock, Preserve)
                    {
                        HSTS,   8, 
                        SSTS,   8, 
                        HSTC,   8, 
                        HCMD,   8, 
                        HADR,   8, 
                        HDT0,   8, 
                        HDT1,   8, 
                        BLKD,   8
                    }

                    Field (SMRG, ByteAcc, NoLock, Preserve)
                    {
                        Offset (0x05), 
                        HDTW,   16
                    }

                    Local0 = 0x05
                    While (Local0)
                    {
                        HADR = Arg0
                        HCMD = Arg1
                        HDTW = Arg2
                        HSTS = 0xFF
                        HSTC = Arg3
                        Local7 = 0xFF
                        While (Local7)
                        {
                            Local7--
                            If ((HSTS & 0x02))
                            {
                                Local7 = Zero
                                Local0 = One
                            }
                        }

                        Local0--
                    }

                    If ((HSTS & 0x02))
                    {
                        Return (HDTW) /* \_SB_.PCI0.SBRG.SCMD.HDTW */
                    }
                    Else
                    {
                        Return (Ones)
                    }
                }

                Method (SBYT, 2, NotSerialized)
                {
                    SCMD (Arg0, Arg1, Zero, 0x44)
                }

                Method (WBYT, 3, NotSerialized)
                {
                    SCMD (Arg0, Arg1, Arg2, 0x48)
                }

                Method (WWRD, 3, NotSerialized)
                {
                    SCMD (Arg0, Arg1, Arg2, 0x4C)
                }

                Method (RSBT, 2, NotSerialized)
                {
                    Arg0 |= One
                    Return (SCMD (Arg0, Arg1, Zero, 0x44))
                }

                Method (RBYT, 2, NotSerialized)
                {
                    Arg0 |= One
                    Return (SCMD (Arg0, Arg1, Zero, 0x48))
                }

                Method (RWRD, 2, NotSerialized)
                {
                    Arg0 |= One
                    Return (SCMD (Arg0, Arg1, Zero, 0x4C))
                }

                Scope (\)
                {
                    OperationRegion (IOB2, SystemIO, 0xB2, 0x02)
                    Field (IOB2, ByteAcc, NoLock, Preserve)
                    {
                        SMIC,   8, 
                        SMIS,   8
                    }

                    Method (ISMI, 1, Serialized)
                    {
                        SMIC = Arg0
                    }

                    Method (DBGR, 2, NotSerialized)
                    {
                        DBR1 = Arg0
                        DBR2 = Arg1
                        ISMI (0x96)
                    }

                    OperationRegion (DBIO, SystemIO, 0x80, One)
                    Field (DBIO, ByteAcc, NoLock, Preserve)
                    {
                        DB80,   8
                    }
                }

                Device (^PCIE)
                {
                    Name (_HID, EisaId ("PNP0C02") /* PNP Motherboard Resources */)  // _HID: Hardware ID
                    Name (_UID, 0x11)  // _UID: Unique ID
                    Name (CRS, ResourceTemplate ()
                    {
                        Memory32Fixed (ReadOnly,
                            0xE0000000,         // Address Base
                            0x10000000,         // Address Length
                            _Y04)
                    })
                    Method (_CRS, 0, NotSerialized)  // _CRS: Current Resource Settings
                    {
                        CreateDWordField (CRS, \_SB.PCI0.PCIE._Y04._BAS, BAS1)  // _BAS: Base Address
                        CreateDWordField (CRS, \_SB.PCI0.PCIE._Y04._LEN, LEN1)  // _LEN: Length
                        BAS1 = PCIB /* \PCIB */
                        LEN1 = PCIL /* \PCIL */
                        Return (CRS) /* \_SB_.PCI0.PCIE.CRS_ */
                    }
                }

                Device (OMSC)
                {
                    Name (_HID, EisaId ("PNP0C02") /* PNP Motherboard Resources */)  // _HID: Hardware ID
                    Name (_UID, Zero)  // _UID: Unique ID
                    Name (CRS, ResourceTemplate ()
                    {
                        Memory32Fixed (ReadOnly,
                            0x00000000,         // Address Base
                            0x00000000,         // Address Length
                            _Y05)
                        Memory32Fixed (ReadOnly,
                            0x00000000,         // Address Base
                            0x00000000,         // Address Length
                            _Y06)
                    })
                    Name (CRS1, ResourceTemplate ()
                    {
                        FixedIO (
                            0x0060,             // Address
                            0x01,               // Length
                            )
                        FixedIO (
                            0x0064,             // Address
                            0x01,               // Length
                            )
                        Memory32Fixed (ReadOnly,
                            0x00000000,         // Address Base
                            0x00000000,         // Address Length
                            _Y07)
                        Memory32Fixed (ReadOnly,
                            0x00000000,         // Address Base
                            0x00000000,         // Address Length
                            _Y08)
                    })
                    Method (_CRS, 0, NotSerialized)  // _CRS: Current Resource Settings
                    {
                        If (APIC)
                        {
                            CreateDWordField (CRS, \_SB.PCI0.SBRG.OMSC._Y05._LEN, ML01)  // _LEN: Length
                            CreateDWordField (CRS, \_SB.PCI0.SBRG.OMSC._Y05._BAS, MB01)  // _BAS: Base Address
                            CreateDWordField (CRS, \_SB.PCI0.SBRG.OMSC._Y06._LEN, ML02)  // _LEN: Length
                            CreateDWordField (CRS, \_SB.PCI0.SBRG.OMSC._Y06._BAS, MB02)  // _BAS: Base Address
                            MB01 = 0xFEC00000
                            ML01 = 0x1000
                            MB02 = 0xFEE00000
                            ML02 = 0x1000
                            CreateDWordField (CRS1, \_SB.PCI0.SBRG.OMSC._Y07._LEN, ML03)  // _LEN: Length
                            CreateDWordField (CRS1, \_SB.PCI0.SBRG.OMSC._Y07._BAS, MB03)  // _BAS: Base Address
                            CreateDWordField (CRS1, \_SB.PCI0.SBRG.OMSC._Y08._LEN, ML04)  // _LEN: Length
                            CreateDWordField (CRS1, \_SB.PCI0.SBRG.OMSC._Y08._BAS, MB04)  // _BAS: Base Address
                            MB03 = 0xFEC00000
                            ML03 = 0x1000
                            MB04 = 0xFEE00000
                            ML04 = 0x1000
                        }

                        Local0 = (0x05 << 0x0A)
                        If ((IOST & Local0))
                        {
                            Return (CRS) /* \_SB_.PCI0.SBRG.OMSC.CRS_ */
                        }
                        Else
                        {
                            Return (CRS1) /* \_SB_.PCI0.SBRG.OMSC.CRS1 */
                        }
                    }
                }

                Device (^^RMEM)
                {
                    Name (_HID, EisaId ("PNP0C01") /* System Board */)  // _HID: Hardware ID
                    Name (_UID, One)  // _UID: Unique ID
                    Name (CRS, ResourceTemplate ()
                    {
                        Memory32Fixed (ReadWrite,
                            0x00000000,         // Address Base
                            0x000A0000,         // Address Length
                            )
                        Memory32Fixed (ReadOnly,
                            0x00000000,         // Address Base
                            0x00000000,         // Address Length
                            _Y09)
                        Memory32Fixed (ReadOnly,
                            0x000E0000,         // Address Base
                            0x00020000,         // Address Length
                            _Y0A)
                        Memory32Fixed (ReadWrite,
                            0x00100000,         // Address Base
                            0x00000000,         // Address Length
                            _Y0B)
                        Memory32Fixed (ReadOnly,
                            0x00000000,         // Address Base
                            0x00000000,         // Address Length
                            _Y0C)
                    })
                    Method (_CRS, 0, NotSerialized)  // _CRS: Current Resource Settings
                    {
                        CreateDWordField (CRS, \_SB.RMEM._Y09._BAS, BAS1)  // _BAS: Base Address
                        CreateDWordField (CRS, \_SB.RMEM._Y09._LEN, LEN1)  // _LEN: Length
                        CreateDWordField (CRS, \_SB.RMEM._Y0A._BAS, BAS2)  // _BAS: Base Address
                        CreateDWordField (CRS, \_SB.RMEM._Y0A._LEN, LEN2)  // _LEN: Length
                        CreateDWordField (CRS, \_SB.RMEM._Y0B._LEN, LEN3)  // _LEN: Length
                        CreateDWordField (CRS, \_SB.RMEM._Y0C._BAS, BAS4)  // _BAS: Base Address
                        CreateDWordField (CRS, \_SB.RMEM._Y0C._LEN, LEN4)  // _LEN: Length
                        If (OSFL ()){}
                        Else
                        {
                            If (MG1B)
                            {
                                If ((MG1B > 0x000C0000))
                                {
                                    BAS1 = 0x000C0000
                                    LEN1 = (MG1B - BAS1) /* \_SB_.RMEM._CRS.BAS1 */
                                }
                            }
                            Else
                            {
                                BAS1 = 0x000C0000
                                LEN1 = 0x00020000
                            }

                            If (Local0 = (MG1B + MG1L) /* \MG1L */)
                            {
                                BAS2 = Local0
                                LEN2 = (0x00100000 - BAS2) /* \_SB_.RMEM._CRS.BAS2 */
                            }
                        }

                        LEN3 = (MG2B - 0x00100000)
                        BAS4 = MH1B /* \MH1B */
                        LEN4 = (Zero - BAS4) /* \_SB_.RMEM._CRS.BAS4 */
                        Return (CRS) /* \_SB_.RMEM.CRS_ */
                    }
                }

                Scope (\)
                {
                    OperationRegion (RAMW, SystemMemory, (TOPM - 0x00010000), 0x00010000)
                    Field (RAMW, ByteAcc, NoLock, Preserve)
                    {
                        PAR0,   32, 
                        PAR1,   32, 
                        ACPF,   8, 
                        DCPF,   8, 
                        LCDC,   8, 
                        CPUC,   8, 
                        PLCK,   8, 
                        FANC,   8, 
                        BLTS,   8, 
                        WLNW,   8, 
                        DBR1,   8, 
                        DBR2,   8, 
                        GNBF,   32, 
                        ACTD,   8, 
                        AVLD,   8, 
                        SETD,   8, 
                        TCRT,   8, 
                        TPSV,   8, 
                        TAC0,   8, 
                        SFUN,   8, 
                        CADL,   16, 
                        PADL,   16, 
                        CSTE,   16, 
                        NSTE,   16, 
                        SSTE,   16, 
                        LCDV,   32, 
                        LCDR,   8
                    }

                    OperationRegion (ECMS, SystemIO, 0x72, 0x02)
                    Field (ECMS, ByteAcc, Lock, Preserve)
                    {
                        EIND,   8, 
                        EDAT,   8
                    }

                    IndexField (EIND, EDAT, ByteAcc, NoLock, Preserve)
                    {
                        Offset (0x50), 
                        IKFG,   8, 
                        FRPN,   16, 
                        RAMB,   32, 
                        AVOL,   8, 
                        LBTN,   8, 
                        ERRF,   8, 
                        WLDP,   1, 
                        BTDP,   1, 
                        WRST,   1, 
                        BRST,   1, 
                        WRPS,   1, 
                        BRPS,   1, 
                        Offset (0x5B), 
                        WIDE,   1, 
                        OVCK,   2, 
                        SLPN,   3, 
                        ACRD,   1, 
                        Offset (0x5C), 
                        CPUR,   6, 
                        CPUF,   2, 
                        LBT2,   8, 
                        PCMS,   8, 
                        CLKS,   8, 
                        CLKL,   8, 
                        CLKD,   128, 
                        ALSL,   8, 
                        ALAE,   1, 
                        ALDE,   1, 
                        ALSP,   1, 
                        Offset (0x73), 
                        SYNA,   1, 
                        ALPS,   1, 
                        Offset (0x74), 
                        IKF2,   8, 
                        UHDB,   8, 
                        OSPM,   8, 
                        TCGF,   8, 
                        PPIS,   8, 
                        PPIR,   8, 
                        OBMM,   8, 
                        SIDE,   1, 
                        PWBS,   1, 
                        Offset (0x7C), 
                        WLRF,   1
                    }
                }

                Device (EC0)
                {
                    Name (_HID, EisaId ("PNP0C09") /* Embedded Controller Device */)  // _HID: Hardware ID
                    Name (_CRS, ResourceTemplate ()  // _CRS: Current Resource Settings
                    {
                        IO (Decode16,
                            0x0062,             // Range Minimum
                            0x0062,             // Range Maximum
                            0x00,               // Alignment
                            0x01,               // Length
                            )
                        IO (Decode16,
                            0x0066,             // Range Minimum
                            0x0066,             // Range Maximum
                            0x00,               // Alignment
                            0x01,               // Length
                            )
                    })
                    Name (_GPE, 0x1F)  // _GPE: General Purpose Events
                    Name (REGC, Zero)
                    Mutex (ASIO, 0x00)
                    Method (_REG, 2, NotSerialized)  // _REG: Region Availability
                    {
                        If ((Arg0 == 0x03))
                        {
                            REGC = Arg1
                        }
                    }

                    Method (ECAV, 0, NotSerialized)
                    {
                        If ((REGC == Ones))
                        {
                            If ((_REV >= 0x02))
                            {
                                Return (One)
                            }
                            Else
                            {
                                Return (Zero)
                            }
                        }

                        Return (REGC) /* \_SB_.PCI0.SBRG.EC0_.REGC */
                    }

                    OperationRegion (ECOR, EmbeddedControl, Zero, 0xFF)
                    Field (ECOR, ByteAcc, Lock, Preserve)
                    {
                        Offset (0x04), 
                        CMD1,   8, 
                        CDT1,   8, 
                        CDT2,   8, 
                        CDT3,   8, 
                        Offset (0x18), 
                        PRTC,   8, 
                        SSTS,   5, 
                            ,   1, 
                        ALFG,   1, 
                        CDFG,   1, 
                        ADDR,   8, 
                        CMDB,   8, 
                        BDAT,   256, 
                        BCNT,   8, 
                            ,   1, 
                        ALAD,   7, 
                        ALD0,   8, 
                        ALD1,   8, 
                        A2AD,   8, 
                        A2D0,   8, 
                        A2D1,   8, 
                        A3AD,   8, 
                        P54D,   8, 
                        P55D,   8, 
                        Offset (0x48), 
                        P54S,   8, 
                        P55S,   8, 
                        P50S,   8, 
                        P43S,   8, 
                        P54T,   8, 
                        P55T,   8, 
                        P50T,   8, 
                        P43T,   8, 
                        P60S,   8, 
                        P61S,   8, 
                        P62S,   8, 
                        P63S,   8, 
                        P64S,   8, 
                        P65S,   8, 
                        P66S,   8, 
                        P67S,   8, 
                        P60T,   8, 
                        P61T,   8, 
                        P62T,   8, 
                        P63T,   8, 
                        P64T,   8, 
                        P65T,   8, 
                        P66T,   8, 
                        P67T,   8, 
                        Offset (0x78), 
                        P60I,   1, 
                        P61I,   1, 
                        P62I,   1, 
                        P63I,   1, 
                        P64I,   1, 
                        P65I,   1, 
                        P66I,   1, 
                        P67I,   1, 
                        Offset (0x80), 
                        EPWS,   8, 
                        EB0S,   8, 
                        EB1S,   8, 
                        EB0R,   8, 
                        EB1R,   8, 
                        EPWF,   8, 
                        Offset (0x87), 
                        EB0T,   8, 
                        EB1T,   8, 
                        Offset (0x93), 
                        TAH0,   16, 
                        TAH1,   16, 
                        TSTP,   8, 
                        Offset (0x9C), 
                        CDT4,   8, 
                        CDT5,   8, 
                        Offset (0xA0), 
                        ECPU,   8, 
                        ECRT,   8, 
                        EPSV,   8, 
                        EACT,   8, 
                        TH1R,   8, 
                        TH1L,   8, 
                        TH0R,   8, 
                        TH0L,   8, 
                        Offset (0xB0), 
                        B0PN,   16, 
                        B0VL,   16, 
                        B0RC,   16, 
                        B0FC,   16, 
                        B0MD,   16, 
                        B0ST,   16, 
                        B0CC,   16, 
                        B0TM,   16, 
                        B0C1,   16, 
                        B0C2,   16, 
                        B0C3,   16, 
                        B0C4,   16, 
                        Offset (0xD0), 
                        B1PN,   16, 
                        B1VL,   16, 
                        B1RC,   16, 
                        B1FC,   16, 
                        B1MD,   16, 
                        B1ST,   16, 
                        B1CC,   16, 
                        B1TM,   16, 
                        B1C1,   16, 
                        B1C2,   16, 
                        B1C3,   16, 
                        B1C4,   16, 
                        Offset (0xF0), 
                        B0DC,   16, 
                        B0DV,   16, 
                        B0SN,   16, 
                        Offset (0xF8), 
                        B1DC,   16, 
                        B1DV,   16, 
                        B1SN,   16
                    }

                    Field (ECOR, ByteAcc, NoLock, Preserve)
                    {
                        Offset (0x1C), 
                        DAT0,   8, 
                        DAT1,   8
                    }

                    Field (ECOR, ByteAcc, NoLock, Preserve)
                    {
                        Offset (0x1C), 
                        DT2B,   16
                    }

                    Field (ECOR, ByteAcc, Lock, Preserve)
                    {
                        Offset (0x48), 
                            ,   4, 
                        P54A,   1, 
                        Offset (0x49), 
                            ,   4, 
                        P55A,   1, 
                        Offset (0x4A), 
                            ,   4, 
                        P50A,   1, 
                        Offset (0x4B), 
                            ,   4, 
                        P43A,   1
                    }

                    Name (SMBF, Zero)
                    OperationRegion (SMB2, EmbeddedControl, 0x40, 0x28)
                    Field (SMB2, ByteAcc, NoLock, Preserve)
                    {
                        PRT2,   8, 
                        SST2,   5, 
                            ,   1, 
                        ALF2,   1, 
                        CDF2,   1, 
                        ADD2,   8, 
                        CMD2,   8, 
                        BDA2,   256, 
                        BCN2,   8, 
                            ,   1, 
                        ALA2,   7, 
                        ALR0,   8, 
                        ALR1,   8
                    }

                    Field (SMB2, ByteAcc, NoLock, Preserve)
                    {
                        Offset (0x04), 
                        DA20,   8, 
                        DA21,   8
                    }

                    Name (LED2, Ones)
                    Name (LED5, Ones)
                    Name (LED4, Ones)
                    Method (EC0S, 1, NotSerialized)
                    {
                    }

                    Method (EC0W, 1, NotSerialized)
                    {
                    }
                }

                Scope (\_SB)
                {
                    Device (SLPB)
                    {
                        Name (_HID, EisaId ("PNP0C0E") /* Sleep Button Device */)  // _HID: Hardware ID
                        Method (_STA, 0, NotSerialized)  // _STA: Status
                        {
                            Return (0x0F)
                        }
                    }
                }

                Scope (EC0)
                {
                    Mutex (MUEC, 0x00)
                    OperationRegion (DLYP, SystemIO, 0xE1, One)
                    Field (DLYP, ByteAcc, NoLock, Preserve)
                    {
                        DELY,   8
                    }

                    OperationRegion (KBCP, SystemIO, 0x60, 0x07)
                    Field (KBCP, ByteAcc, Lock, Preserve)
                    {
                        KBCD,   8, 
                        Offset (0x02), 
                        EC62,   8, 
                        Offset (0x04), 
                        KBCC,   8, 
                        Offset (0x06), 
                        EC66,   8
                    }

                    Field (KBCP, ByteAcc, Lock, Preserve)
                    {
                        Offset (0x04), 
                        KBOF,   1, 
                        KBIE,   1, 
                        Offset (0x05), 
                        Offset (0x06), 
                        ECOF,   1, 
                        ECIE,   1, 
                        Offset (0x07)
                    }

                    Method (IBFR, 0, Serialized)
                    {
                        Local0 = 0x1000
                        While ((Local0-- && KBIE))
                        {
                            DELY = Zero
                        }
                    }

                    Method (OBFL, 0, Serialized)
                    {
                        Local0 = 0x1000
                        While ((Local0-- && !KBOF))
                        {
                            DELY = Zero
                        }
                    }

                    Method (WKBC, 2, Serialized)
                    {
                        IBFR ()
                        KBCC = Arg0
                        IBFR ()
                        KBCD = Arg1
                        IBFR ()
                    }

                    Method (RECR, 1, Serialized)
                    {
                        WKBC (0xB8, Arg0)
                        KBCC = 0xBC
                        IBFR ()
                        OBFL ()
                        Return (KBCD) /* \_SB_.PCI0.SBRG.EC0_.KBCD */
                    }

                    Method (WECR, 2, Serialized)
                    {
                        WKBC (0xB8, Arg0)
                        WKBC (0xBD, Arg1)
                    }

                    Method (WCMD, 1, Serialized)
                    {
                        If (ECAV ())
                        {
                            If (!Acquire (MUEC, 0xFFFF))
                            {
                                CMD1 = Arg0
                                Release (MUEC)
                            }
                        }
                    }

                    Method (ECCM, 3, Serialized)
                    {
                        If (!Acquire (MUEC, 0xFFFF))
                        {
                            If (ECAV ())
                            {
                                CDT1 = Arg0
                                CDT2 = Arg1
                                CMD1 = Arg2
                                Local0 = 0x1388
                                While ((Local0-- && CMD1))
                                {
                                    Stall (0x0A)
                                }

                                If (CMD1)
                                {
                                    Local0 = Ones
                                }
                                Else
                                {
                                    Local0 = CDT1 /* \_SB_.PCI0.SBRG.EC0_.CDT1 */
                                }
                            }

                            Release (MUEC)
                        }

                        Return (Local0)
                    }

                    Method (RPIN, 1, Serialized)
                    {
                        Local0 = (Arg0 & 0x1F)
                        Local1 = STC5 (Local0)
                        Return (Local1)
                    }

                    Method (SPIN, 2, Serialized)
                    {
                        Local0 = Arg0
                        If (Arg1)
                        {
                            Local0 |= 0x20
                        }
                        Else
                        {
                            Local0 |= 0x40
                        }

                        STC5 (Local0)
                        Return (One)
                    }

                    Method (ST87, 2, Serialized)
                    {
                        If (ECAV ())
                        {
                            If ((Acquire (MUEC, 0xFFFF) == Zero))
                            {
                                CDT1 = 0x87
                                CDT2 = Arg0
                                CDT3 = Arg1
                                CMD1 = 0xB6
                                Local0 = 0x7F
                                While ((Local0 && CMD1))
                                {
                                    Sleep (One)
                                    Local0--
                                }

                                If ((CMD1 == Zero))
                                {
                                    Local0 = CDT1 /* \_SB_.PCI0.SBRG.EC0_.CDT1 */
                                }
                                Else
                                {
                                    Local0 = Ones
                                }

                                Release (MUEC)
                                Return (Local0)
                            }
                        }

                        Return (Ones)
                    }

                    Method (STC5, 1, Serialized)
                    {
                        If (ECAV ())
                        {
                            If ((Acquire (MUEC, 0xFFFF) == Zero))
                            {
                                CDT1 = Arg0
                                CMD1 = 0xC5
                                Local0 = 0x7F
                                While ((Local0 && CMD1))
                                {
                                    Sleep (One)
                                    Local0--
                                }

                                If ((CMD1 == Zero))
                                {
                                    Local0 = CDT1 /* \_SB_.PCI0.SBRG.EC0_.CDT1 */
                                }
                                Else
                                {
                                    Local0 = Ones
                                }

                                Release (MUEC)
                                Return (Local0)
                            }
                        }

                        Return (Ones)
                    }

                    Method (RDC3, 1, Serialized)
                    {
                        Return (ECCM (Arg0, 0xFF, 0xC3))
                    }

                    Method (WEIE, 0, Serialized)
                    {
                        Local0 = 0x4000
                        Local1 = (AEIC & 0x02)
                        While (((Local0 != Zero) && (Local1 == 0x02)))
                        {
                            Local1 = (AEIC & 0x02)
                            Local0--
                        }
                    }

                    Method (WEOF, 0, Serialized)
                    {
                        Local0 = 0x4000
                        Local1 = (AEIC & One)
                        While (((Local0 != Zero) && (Local1 == Zero)))
                        {
                            Local1 = (AEIC & One)
                            Local0--
                        }
                    }

                    Method (ESMR, 3, Serialized)
                    {
                        If (ECAV ())
                        {
                            If (!Acquire (MUEC, 0xFFFF))
                            {
                                ADDR = (Arg0 | One)
                                CMDB = Arg1
                                PRTC = Arg2
                                Local0 = 0x64
                                While ((PRTC && Local0--))
                                {
                                    Sleep (One)
                                }

                                If ((PRTC || SSTS))
                                {
                                    Local0 = Ones
                                }
                                Else
                                {
                                    Local0 = DT2B /* \_SB_.PCI0.SBRG.EC0_.DT2B */
                                }

                                Release (MUEC)
                                Return (Local0)
                            }
                        }

                        Return (Ones)
                    }

                    Method (GPWS, 0, Serialized)
                    {
                        If (ECAV ())
                        {
                            Local0 = (EPWS & 0x07)
                        }
                        Else
                        {
                            Local0 = Zero
                        }

                        Return (Local0)
                    }

                    Name (WRQK, 0x02)
                    Name (RDQK, 0x03)
                    Name (SDBT, 0x04)
                    Name (RCBT, 0x05)
                    Name (WRBT, 0x06)
                    Name (RDBT, 0x07)
                    Name (WRWD, 0x08)
                    Name (RDWD, 0x09)
                    Name (WRBL, 0x0A)
                    Name (RDBL, 0x0B)
                    Name (PCLL, 0x0C)
                    Name (GOOD, Zero)
                    Name (UKER, 0x07)
                    Name (DAER, 0x10)
                    Name (CMDN, 0x12)
                    Name (UKE2, 0x13)
                    Name (DADN, 0x17)
                    Name (SBTO, 0x18)
                    Name (USPT, 0x19)
                    Name (SBBY, 0x1A)
                    Method (SWTC, 1, Serialized)
                    {
                        Local0 = UKER /* \_SB_.PCI0.SBRG.EC0_.UKER */
                        Local1 = 0x03
                        While ((Local0 && Local1))
                        {
                            Local2 = 0x23
                            While (Local2)
                            {
                                If (PRTC)
                                {
                                    Sleep (One)
                                    Local2--
                                }
                                Else
                                {
                                    Local2 = Zero
                                    Local0 = SSTS /* \_SB_.PCI0.SBRG.EC0_.SSTS */
                                }
                            }

                            If (Local0)
                            {
                                PRTC = Zero
                                Local1--
                                If (Local1)
                                {
                                    Sleep (One)
                                    PRTC = Arg0
                                }
                            }
                        }

                        Return (Local0)
                    }

                    Method (SMBR, 3, Serialized)
                    {
                        Local0 = Package (0x03)
                            {
                                0x07, 
                                Zero, 
                                Zero
                            }
                        If (!ECAV ())
                        {
                            Return (Local0)
                        }

                        If ((Arg0 != RDBL))
                        {
                            If ((Arg0 != RDWD))
                            {
                                If ((Arg0 != RDBT))
                                {
                                    If ((Arg0 != RCBT))
                                    {
                                        If ((Arg0 != RDQK))
                                        {
                                            Return (Local0)
                                        }
                                    }
                                }
                            }
                        }

                        If ((Acquire (MUEC, 0xFFFF) == Zero))
                        {
                            Local1 = PRTC /* \_SB_.PCI0.SBRG.EC0_.PRTC */
                            Local2 = Zero
                            While ((Local1 != Zero))
                            {
                                Stall (0x0A)
                                Local2++
                                If ((Local2 > 0x03E8))
                                {
                                    Local0 [Zero] = SBBY /* \_SB_.PCI0.SBRG.EC0_.SBBY */
                                    Local1 = Zero
                                }
                                Else
                                {
                                    Local1 = PRTC /* \_SB_.PCI0.SBRG.EC0_.PRTC */
                                }
                            }

                            If ((Local2 <= 0x03E8))
                            {
                                Local3 = (Arg1 << One)
                                Local3 |= One
                                ADDR = Local3
                                If ((Arg0 != RDQK))
                                {
                                    If ((Arg0 != RCBT))
                                    {
                                        CMDB = Arg2
                                    }
                                }

                                PRTC = Arg0
                                Local0 [Zero] = SWTC (Arg0)
                                If ((DerefOf (Local0 [Zero]) == Zero))
                                {
                                    If ((Arg0 == RDBL))
                                    {
                                        Local0 [One] = BCNT /* \_SB_.PCI0.SBRG.EC0_.BCNT */
                                        Local0 [0x02] = BDAT /* \_SB_.PCI0.SBRG.EC0_.BDAT */
                                    }

                                    If ((Arg0 == RDWD))
                                    {
                                        Local0 [One] = 0x02
                                        Local0 [0x02] = DT2B /* \_SB_.PCI0.SBRG.EC0_.DT2B */
                                    }

                                    If ((Arg0 == RDBT))
                                    {
                                        Local0 [One] = One
                                        Local0 [0x02] = DAT0 /* \_SB_.PCI0.SBRG.EC0_.DAT0 */
                                    }

                                    If ((Arg0 == RCBT))
                                    {
                                        Local0 [One] = One
                                        Local0 [0x02] = DAT0 /* \_SB_.PCI0.SBRG.EC0_.DAT0 */
                                    }
                                }
                            }

                            Release (MUEC)
                        }

                        Return (Local0)
                    }

                    Method (GBTT, 1, Serialized)
                    {
                        If (ECAV ())
                        {
                            If ((Arg0 == Zero))
                            {
                                Local0 = EB0T /* \_SB_.PCI0.SBRG.EC0_.EB0T */
                            }
                            Else
                            {
                                Local0 = EB1T /* \_SB_.PCI0.SBRG.EC0_.EB1T */
                            }
                        }
                        Else
                        {
                            Local0 = 0xFF
                        }

                        Return (Local0)
                    }

                    Method (ECXT, 6, NotSerialized)
                    {
                        Local1 = Package (0x06)
                            {
                                0x10, 
                                Zero, 
                                Zero, 
                                Zero, 
                                Zero, 
                                Zero
                            }
                        If (ECAV ())
                        {
                            If ((Acquire (MUEC, 0xFFFF) == Zero))
                            {
                                CDT1 = Arg1
                                CDT2 = Arg2
                                CDT3 = Arg3
                                CDT4 = Arg4
                                CDT5 = Arg5
                                CMD1 = Arg0
                                Local0 = 0x7F
                                While ((Local0 && CMD1))
                                {
                                    Sleep (One)
                                    Local0--
                                }

                                If (Local0)
                                {
                                    Local1 [Zero] = Zero
                                    Local1 [One] = CDT1 /* \_SB_.PCI0.SBRG.EC0_.CDT1 */
                                    Local1 [0x02] = CDT2 /* \_SB_.PCI0.SBRG.EC0_.CDT2 */
                                    Local1 [0x03] = CDT3 /* \_SB_.PCI0.SBRG.EC0_.CDT3 */
                                    Local1 [0x04] = CDT4 /* \_SB_.PCI0.SBRG.EC0_.CDT4 */
                                    Local1 [0x05] = CDT5 /* \_SB_.PCI0.SBRG.EC0_.CDT5 */
                                }
                                Else
                                {
                                    Local1 [Zero] = 0x10
                                }

                                Release (MUEC)
                            }
                        }

                        Return (Local1)
                    }

                    Method (ECSB, 6, NotSerialized)
                    {
                        Local1 = Package (0x05)
                            {
                                0x11, 
                                Zero, 
                                Zero, 
                                Zero, 
                                Zero
                            }
                        If ((Arg0 > One))
                        {
                            Return (Local1)
                        }

                        If (ECAV ())
                        {
                            If ((Acquire (MUEC, 0xFFFF) == Zero))
                            {
                                If ((Arg0 == Zero))
                                {
                                    ADDR = Arg2
                                    CMDB = Arg3
                                    DAT0 = Arg4
                                    DAT1 = Arg5
                                    PRTC = Arg1
                                }
                                Else
                                {
                                    ADD2 = Arg2
                                    CMD2 = Arg3
                                    DA20 = Arg4
                                    DA21 = Arg5
                                    PRT2 = Arg1
                                }

                                Local0 = 0x7F
                                While (PRTC)
                                {
                                    Sleep (One)
                                    Local0--
                                }

                                If (Local0)
                                {
                                    If ((Arg0 == Zero))
                                    {
                                        Local0 = SSTS /* \_SB_.PCI0.SBRG.EC0_.SSTS */
                                        Local1 [One] = DAT0 /* \_SB_.PCI0.SBRG.EC0_.DAT0 */
                                        Local1 [0x02] = DAT1 /* \_SB_.PCI0.SBRG.EC0_.DAT1 */
                                        Local1 [0x03] = BCNT /* \_SB_.PCI0.SBRG.EC0_.BCNT */
                                        Local1 [0x04] = BDAT /* \_SB_.PCI0.SBRG.EC0_.BDAT */
                                    }
                                    Else
                                    {
                                        Local0 = SST2 /* \_SB_.PCI0.SBRG.EC0_.SST2 */
                                        Local1 [One] = DA20 /* \_SB_.PCI0.SBRG.EC0_.DA20 */
                                        Local1 [0x02] = DA21 /* \_SB_.PCI0.SBRG.EC0_.DA21 */
                                        Local1 [0x03] = BCN2 /* \_SB_.PCI0.SBRG.EC0_.BCN2 */
                                        Local1 [0x04] = BDA2 /* \_SB_.PCI0.SBRG.EC0_.BDA2 */
                                    }

                                    Local0 &= 0x1F
                                    If (Local0)
                                    {
                                        Local0 += 0x10
                                    }

                                    Local1 [Zero] = Local0
                                }
                                Else
                                {
                                    Local1 [Zero] = 0x10
                                }

                                Release (MUEC)
                            }
                        }

                        Return (Local1)
                    }

                    OperationRegion (KAID, SystemIO, 0x68, One)
                    Field (KAID, ByteAcc, NoLock, Preserve)
                    {
                        AEID,   8
                    }

                    OperationRegion (KAIC, SystemIO, 0x6C, One)
                    Field (KAIC, ByteAcc, NoLock, Preserve)
                    {
                        AEIC,   8
                    }

                    Method (RFOV, 1, Serialized)
                    {
                        Local0 = Zero
                        If ((Acquire (ASIO, 0xFFFF) == Zero))
                        {
                            WEIE ()
                            AEIC = 0x83
                            WEIE ()
                            AEID = Arg0
                            WEOF ()
                            Local0 = AEID /* \_SB_.PCI0.SBRG.EC0_.AEID */
                            WEIE ()
                            Release (ASIO)
                        }

                        Return (Local0)
                    }

                    Method (WFOV, 2, Serialized)
                    {
                        If ((Acquire (ASIO, 0xFFFF) == Zero))
                        {
                            WEIE ()
                            AEIC = 0x84
                            WEIE ()
                            AEID = Arg0
                            WEIE ()
                            AEID = Arg1
                            Release (ASIO)
                        }
                    }

                    Method (RBOV, 1, Serialized)
                    {
                        Local0 = Zero
                        If ((Acquire (ASIO, 0xFFFF) == Zero))
                        {
                            WEIE ()
                            AEIC = 0x85
                            WEIE ()
                            AEID = Arg0
                            WEOF ()
                            Local0 = AEID /* \_SB_.PCI0.SBRG.EC0_.AEID */
                            WEIE ()
                            Release (ASIO)
                        }

                        Return (Local0)
                    }

                    Method (WBOV, 2, Serialized)
                    {
                        If ((Acquire (ASIO, 0xFFFF) == Zero))
                        {
                            WEIE ()
                            AEIC = 0x86
                            WEIE ()
                            AEID = Arg0
                            WEIE ()
                            AEID = Arg1
                            Release (ASIO)
                        }
                    }

                    Method (WMFN, 1, Serialized)
                    {
                        If ((Acquire (ASIO, 0xFFFF) == Zero))
                        {
                            WEIE ()
                            AEIC = 0x98
                            WEIE ()
                            AEID = Arg0
                            WEIE ()
                            Release (ASIO)
                        }
                    }

                    Method (STBR, 0, Serialized)
                    {
                        If (ACPS ())
                        {
                            Local0 = DerefOf (PWAC [LBTN])
                        }
                        Else
                        {
                            Local0 = DerefOf (PWDC [LBTN])
                        }

                        WBOV (Zero, Local0)
                    }
                }

                Scope (\)
                {
                    Method (ACPS, 0, Serialized)
                    {
                        Return ((\_SB.PCI0.SBRG.EC0.GPWS () & One))
                    }

                    Method (DCPS, 1, Serialized)
                    {
                        Local0 = \_SB.PCI0.SBRG.EC0.ST87 (Zero, 0x26)
                        Local0 ^= One
                        Return (Local0)
                    }

                    Method (ECRB, 1, Serialized)
                    {
                        Return ((\_SB.PCI0.SBRG.EC0.ESMR (0x16, Arg0, 0x07) & 0xFFFF))
                    }

                    Method (ECRW, 1, Serialized)
                    {
                        Return (\_SB.PCI0.SBRG.EC0.ESMR (0x16, Arg0, 0x09))
                    }

                    Method (ECIO, 1, Serialized)
                    {
                        Local0 = Ones
                        While ((Local0 == Ones))
                        {
                            Local0 = \_SB.PCI0.SBRG.EC0.RDC3 ((Arg0 >> 0x04))
                        }

                        Local0 >>= (Arg0 & 0x0F)
                        Return ((One & Local0))
                    }
                }

                Scope (\_TZ)
                {
                    Name (ATMP, 0x3C)
                    Name (LTMP, 0x3C)
                    Name (FANS, Zero)
                    Method (RTMP, 0, NotSerialized)
                    {
                        If (\_SB.PCI0.SBRG.EC0.ECAV ())
                        {
                            Local0 = \_SB.PCI0.SBRG.EC0.ECPU
                            If ((Local0 < 0x80))
                            {
                                LTMP = Local0
                            }
                        }

                        Return (LTMP) /* \_TZ_.LTMP */
                    }

                    Method (RLTM, 0, NotSerialized)
                    {
                        If (\_SB.PCI0.SBRG.EC0.ECAV ())
                        {
                            Local0 = \_SB.PCI0.SBRG.EC0.TH0L
                            If ((Local0 < 0x80))
                            {
                                ATMP = Local0
                            }
                        }

                        Return (ATMP) /* \_TZ_.ATMP */
                    }

                    Method (RCRT, 0, NotSerialized)
                    {
                        If (\_SB.PCI0.SBRG.EC0.ECAV ())
                        {
                            Local0 = \_SB.PCI0.SBRG.EC0.ECRT
                            If ((Local0 < 0x80))
                            {
                                Local0--
                                TCRT = Local0
                            }
                        }
                    }

                    Method (RPSV, 0, NotSerialized)
                    {
                        If (\_SB.PCI0.SBRG.EC0.ECAV ())
                        {
                            Local0 = \_SB.PCI0.SBRG.EC0.EPSV
                            If ((Local0 < 0x80))
                            {
                                TPSV = Local0
                            }
                        }
                    }
                }

                Scope (^^PCI0)
                {
                    Device (BAT0)
                    {
                        Name (_HID, EisaId ("PNP0C0A") /* Control Method Battery */)  // _HID: Hardware ID
                        Name (_UID, Zero)  // _UID: Unique ID
                        Name (_PCL, Package (0x01)  // _PCL: Power Consumer List
                        {
                            PCI0
                        })
                        Method (_STA, 0, NotSerialized)  // _STA: Status
                        {
                            DBGR (0x30, One)
                            Local1 = ^^SBRG.EC0.ST87 (Zero, 0x26)
                            If (Local1)
                            {
                                Return (0x0F)
                            }
                            Else
                            {
                                Return (0x1F)
                            }
                        }

                        Name (LOW2, 0x012C)
                        Name (DVOT, 0x0E)
                        Name (PUNT, One)
                        Name (LFCC, 0x1770)
                        Name (NBIF, Package (0x0D)
                        {
                            Zero, 
                            Ones, 
                            Ones, 
                            One, 
                            Ones, 
                            Ones, 
                            Ones, 
                            Ones, 
                            Ones, 
                            "", 
                            "", 
                            "", 
                            ""
                        })
                        Name (PBIF, Package (0x0D)
                        {
                            One, 
                            0x1770, 
                            0x1770, 
                            One, 
                            0x39D0, 
                            0x0258, 
                            0x012C, 
                            0x3C, 
                            0x3C, 
                            "M3N", 
                            "", 
                            "LIon", 
                            "PEGATRON"
                        })
                        Name (PBST, Package (0x04)
                        {
                            Zero, 
                            Ones, 
                            Ones, 
                            Ones
                        })
                        Method (FBIF, 5, NotSerialized)
                        {
                            PUNT = Arg0
                            Local1 = Arg1
                            Local2 = Arg2
                            If ((PUNT == Zero))
                            {
                                Local1 *= 0x0A
                                Local2 *= 0x0A
                            }

                            PBIF [Zero] = Arg0
                            PBIF [One] = Local1
                            PBIF [0x02] = Local2
                            LFCC = Local2
                            PBIF [0x03] = Arg3
                            PBIF [0x04] = Arg4
                            Divide (Local1, 0x0A, Local3, Local5)
                            PBIF [0x05] = Local5
                            Local6 = (Local5 >> One)
                            PBIF [0x06] = Local6
                            LOW2 = Local6
                            Divide (Local1, 0x64, Local3, Local7)
                            PBIF [0x07] = Local7
                            PBIF [0x08] = Local7
                        }

                        Method (CBIF, 0, NotSerialized)
                        {
                            If (PUNT)
                            {
                                Local0 = DerefOf (PBIF [0x04])
                                Local0 += 0x01F4
                                Divide (Local0, 0x03E8, Local1, DVOT) /* \_SB_.PCI0.BAT0.DVOT */
                                PBIF [Zero] = Zero
                                PBIF [One] = (DerefOf (PBIF [One]) * DVOT) /* \_SB_.PCI0.BAT0.DVOT */
                                PBIF [0x02] = (DerefOf (PBIF [0x02]) * DVOT) /* \_SB_.PCI0.BAT0.DVOT */
                                PBIF [0x05] = (DerefOf (PBIF [0x05]) * DVOT) /* \_SB_.PCI0.BAT0.DVOT */
                                PBIF [0x06] = (DerefOf (PBIF [0x06]) * DVOT) /* \_SB_.PCI0.BAT0.DVOT */
                                PBIF [0x07] = (DerefOf (PBIF [0x07]) * DVOT) /* \_SB_.PCI0.BAT0.DVOT */
                                PBIF [0x08] = (DerefOf (PBIF [0x08]) * DVOT) /* \_SB_.PCI0.BAT0.DVOT */
                            }
                        }

                        Method (_BIF, 0, NotSerialized)  // _BIF: Battery Information
                        {
                            DBGR (0x40, One)
                            If (!^^SBRG.EC0.BATP (Zero))
                            {
                                Return (NBIF) /* \_SB_.PCI0.BAT0.NBIF */
                            }

                            If ((^^SBRG.EC0.GBTT (Zero) == 0xFF))
                            {
                                Return (NBIF) /* \_SB_.PCI0.BAT0.NBIF */
                            }

                            PBIF [0x09] = ^^SBRG.EC0.BIF9 ()
                            Local0 = ^^SBRG.EC0.BIF0 ()
                            Local1 = ^^SBRG.EC0.BIF1 ()
                            Local2 = ^^SBRG.EC0.BIF2 ()
                            Local3 = ^^SBRG.EC0.BIF3 ()
                            Local4 = ^^SBRG.EC0.BIF4 ()
                            If ((Local0 != Ones))
                            {
                                If ((Local1 != Ones))
                                {
                                    If ((Local2 != Ones))
                                    {
                                        If ((Local3 != Ones))
                                        {
                                            If ((Local4 != Ones))
                                            {
                                                FBIF (Local0, Local1, Local2, Local3, Local4)
                                                CBIF ()
                                            }
                                        }
                                    }
                                }
                            }

                            If ((PUNT == Zero))
                            {
                                Local2 *= 0x0A
                            }

                            LFCC = Local2
                            Return (PBIF) /* \_SB_.PCI0.BAT0.PBIF */
                        }

                        Method (FBST, 4, NotSerialized)
                        {
                            Local1 = (Arg1 & 0xFFFF)
                            Local0 = Zero
                            If ((ACPF == One))
                            {
                                Local0 = One
                            }

                            If (Local0)
                            {
                                If (CHGS (Zero))
                                {
                                    Local0 = 0x02
                                }
                                Else
                                {
                                    Local0 = Zero
                                }
                            }
                            Else
                            {
                                Local0 = One
                            }

                            Local2 = (Arg0 & 0x0300)
                            If (Local2)
                            {
                                Local2 = (One << 0x02)
                                Local0 |= Local2
                            }

                            If ((Local1 >= 0x8000))
                            {
                                Local1 = (0xFFFF - Local1)
                            }

                            Local2 = Arg2
                            If ((PUNT == Zero))
                            {
                                Local1 *= DVOT /* \_SB_.PCI0.BAT0.DVOT */
                                Local2 *= 0x0A
                            }

                            Local3 = (Local0 & 0x02)
                            If (!Local3)
                            {
                                Local3 = (LFCC - Local2)
                                Divide (LFCC, 0xC8, Local4, Local5)
                                If ((Local3 < Local5))
                                {
                                    Local2 = LFCC /* \_SB_.PCI0.BAT0.LFCC */
                                }
                            }
                            Else
                            {
                                Divide (LFCC, 0xC8, Local4, Local5)
                                Local4 = (LFCC - Local5)
                                If ((Local2 > Local4))
                                {
                                    Local2 = Local4
                                }
                            }

                            PBST [Zero] = Local0
                            PBST [One] = Local1
                            PBST [0x02] = Local2
                            PBST [0x03] = Arg3
                        }

                        Method (CBST, 0, NotSerialized)
                        {
                            If (PUNT)
                            {
                                PBST [One] = (DerefOf (PBST [One]) * DVOT) /* \_SB_.PCI0.BAT0.DVOT */
                                PBST [0x02] = (DerefOf (PBST [0x02]) * DVOT) /* \_SB_.PCI0.BAT0.DVOT */
                            }
                        }

                        Method (_BST, 0, NotSerialized)  // _BST: Battery Status
                        {
                            If (!^^SBRG.EC0.BATP (Zero))
                            {
                                PBST [Zero] = Zero
                                PBST [One] = Ones
                                PBST [0x02] = Ones
                                PBST [0x03] = Ones
                                Return (PBST) /* \_SB_.PCI0.BAT0.PBST */
                            }

                            If ((^^SBRG.EC0.GBTT (Zero) == 0xFF))
                            {
                                PBST [Zero] = Zero
                                PBST [One] = Ones
                                PBST [0x02] = Ones
                                PBST [0x03] = Ones
                                Return (PBST) /* \_SB_.PCI0.BAT0.PBST */
                            }

                            Local0 = ^^SBRG.EC0.BSTS ()
                            Local1 = ^^SBRG.EC0.BCRT ()
                            Local2 = ^^SBRG.EC0.BRCP ()
                            Local3 = ^^SBRG.EC0.BVOT ()
                            If ((Local0 != Ones))
                            {
                                If ((Local1 != Ones))
                                {
                                    If ((Local2 != Ones))
                                    {
                                        If ((Local3 != Ones))
                                        {
                                            FBST (Local0, Local1, Local2, Local3)
                                            CBST ()
                                        }
                                    }
                                }
                            }

                            Return (PBST) /* \_SB_.PCI0.BAT0.PBST */
                        }

                        Method (CHGS, 1, Serialized)
                        {
                            Local0 = ^^SBRG.EC0.BCHG (Arg0)
                            Return (Local0)
                        }
                    }
                }

                Scope (EC0)
                {
                    Name (BADR, 0x0B)
                    Name (CADR, 0x09)
                    Name (SADR, 0x0A)
                    Method (BIF0, 0, NotSerialized)
                    {
                        If (ECAV ())
                        {
                            Local0 = B0MD /* \_SB_.PCI0.SBRG.EC0_.B0MD */
                            If ((Local0 != 0xFFFF))
                            {
                                Local1 = (Local0 >> 0x0F)
                                Local1 &= One
                                Local0 = (Local1 ^ One)
                            }
                        }
                        Else
                        {
                            Local0 = Ones
                        }

                        Return (Local0)
                    }

                    Method (BIF1, 0, NotSerialized)
                    {
                        If (ECAV ())
                        {
                            Local0 = B0DC /* \_SB_.PCI0.SBRG.EC0_.B0DC */
                            Local0 &= 0xFFFF
                        }
                        Else
                        {
                            Local0 = Ones
                        }

                        Return (Local0)
                    }

                    Method (BIF2, 0, NotSerialized)
                    {
                        If (ECAV ())
                        {
                            Local0 = B0FC /* \_SB_.PCI0.SBRG.EC0_.B0FC */
                            Local0 &= 0xFFFF
                        }
                        Else
                        {
                            Local0 = Ones
                        }

                        Return (Local0)
                    }

                    Method (BIF3, 0, NotSerialized)
                    {
                        If (ECAV ())
                        {
                            Local0 = B0MD /* \_SB_.PCI0.SBRG.EC0_.B0MD */
                            If ((Local0 != 0xFFFF))
                            {
                                Local0 >>= 0x09
                                Local0 &= One
                                Local0 ^= One
                            }
                        }
                        Else
                        {
                            Local0 = Ones
                        }

                        Return (Local0)
                    }

                    Method (BIF4, 0, NotSerialized)
                    {
                        If (ECAV ())
                        {
                            Local0 = B0DV /* \_SB_.PCI0.SBRG.EC0_.B0DV */
                        }
                        Else
                        {
                            Local0 = Ones
                        }

                        Return (Local0)
                    }

                    Method (BIF9, 0, NotSerialized)
                    {
                        Name (BSTR, Buffer (0x20){})
                        BSTR = "PEGATRON"
                        BSTR [0x04] = Zero
                        Return (BSTR) /* \_SB_.PCI0.SBRG.EC0_.BIF9.BSTR */
                    }

                    Method (BIFA, 0, NotSerialized)
                    {
                        If (ECAV ())
                        {
                            Local0 = B0SN /* \_SB_.PCI0.SBRG.EC0_.B0SN */
                        }
                        Else
                        {
                            Local0 = Ones
                        }

                        Return (Local0)
                    }

                    Method (BSTS, 0, NotSerialized)
                    {
                        If (ECAV ())
                        {
                            Local0 = B0ST /* \_SB_.PCI0.SBRG.EC0_.B0ST */
                        }
                        Else
                        {
                            Local0 = Ones
                        }

                        Return (Local0)
                    }

                    Method (BCRT, 0, NotSerialized)
                    {
                        If (ECAV ())
                        {
                            Local0 = B0CC /* \_SB_.PCI0.SBRG.EC0_.B0CC */
                        }
                        Else
                        {
                            Local0 = Ones
                        }

                        Return (Local0)
                    }

                    Method (BRCP, 0, NotSerialized)
                    {
                        If (ECAV ())
                        {
                            Local0 = B0RC /* \_SB_.PCI0.SBRG.EC0_.B0RC */
                            If ((Local0 == 0xFFFF))
                            {
                                Local0 = Ones
                            }
                        }
                        Else
                        {
                            Local0 = Ones
                        }

                        Return (Local0)
                    }

                    Method (BVOT, 0, NotSerialized)
                    {
                        If (ECAV ())
                        {
                            Local0 = B0VL /* \_SB_.PCI0.SBRG.EC0_.B0VL */
                        }
                        Else
                        {
                            Local0 = Ones
                        }

                        Return (Local0)
                    }

                    Method (BCLE, 1, Serialized)
                    {
                        If (Arg0)
                        {
                            If (ECAV ())
                            {
                                Local1 = EB1S /* \_SB_.PCI0.SBRG.EC0_.EB1S */
                                Local1 &= 0xFFFF
                                If ((Local1 != 0xFFFF))
                                {
                                    Local1 &= 0x16
                                    If ((Local1 == 0x04))
                                    {
                                        Local0 = Zero
                                    }
                                    ElseIf ((Local1 == 0x02))
                                    {
                                        Local0 = One
                                    }
                                    ElseIf ((Local1 == 0x10))
                                    {
                                        Local0 = One
                                    }
                                }

                                Local0 = Ones
                            }
                            Else
                            {
                                Local0 = Ones
                            }

                            Return (Local0)
                        }
                        Else
                        {
                            If (ECAV ())
                            {
                                Local1 = EB0S /* \_SB_.PCI0.SBRG.EC0_.EB0S */
                                Local1 &= 0xFFFF
                                If ((Local1 != 0xFFFF))
                                {
                                    Local1 &= 0x16
                                    If ((Local1 == 0x04))
                                    {
                                        Local0 = Zero
                                    }
                                    ElseIf ((Local1 == 0x02))
                                    {
                                        Local0 = One
                                    }
                                    ElseIf ((Local1 == 0x10))
                                    {
                                        Local0 = One
                                    }
                                }

                                Local0 = Ones
                            }
                            Else
                            {
                                Local0 = Ones
                            }

                            Return (Local0)
                        }
                    }

                    Method (_QA1, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
                    {
                        DCPF = DCPS (Zero)
                        If (DCPF)
                        {
                            Sleep (0x07D0)
                        }

                        Notify (BAT0, 0x80) // Status Change
                        Notify (BAT0, 0x81) // Information Change
                    }

                    Method (_QA5, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
                    {
                        If (ATKP)
                        {
                            Notify (ATKD, 0x6E) // Reserved
                        }
                        ElseIf (BATP (Zero))
                        {
                            Notify (BAT0, 0x80) // Status Change
                        }
                    }

                    Method (_QA3, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
                    {
                        If (BATP (Zero))
                        {
                            Local0 = BCLE (Zero)
                            If ((Local0 == Zero))
                            {
                                Notify (BAT0, 0x80) // Status Change
                            }
                            Else
                            {
                                Notify (AC0, 0x80) // Status Change
                            }
                        }
                    }

                    Method (NBAT, 1, NotSerialized)
                    {
                        If (BATP (Zero))
                        {
                            Notify (BAT0, Arg0)
                        }
                    }

                    Method (BATP, 1, Serialized)
                    {
                        Return (DCPF) /* \DCPF */
                    }

                    Method (BCHG, 1, Serialized)
                    {
                        If (Arg0)
                        {
                            If (ECAV ())
                            {
                                Local0 = EB1S /* \_SB_.PCI0.SBRG.EC0_.EB1S */
                                Local0 &= 0xFF
                                If ((Local0 != 0xFF))
                                {
                                    Local0 &= 0x02
                                }
                                Else
                                {
                                    Local0 = Zero
                                }
                            }
                            Else
                            {
                                Local0 = Zero
                            }

                            Return (Local0)
                        }
                        Else
                        {
                            If (ECAV ())
                            {
                                Local0 = EB0S /* \_SB_.PCI0.SBRG.EC0_.EB0S */
                                Local0 &= 0xFF
                                If ((Local0 != 0xFF))
                                {
                                    Local0 &= 0x02
                                }
                                Else
                                {
                                    Local0 = Zero
                                }
                            }
                            Else
                            {
                                Local0 = Zero
                            }

                            Return (Local0)
                        }
                    }
                }

                Scope (\_SB)
                {
                    Scope (PCI0)
                    {
                        Device (AC0)
                        {
                            Name (_HID, "ACPI0003" /* Power Source Device */)  // _HID: Hardware ID
                            Method (_PSR, 0, NotSerialized)  // _PSR: Power Source
                            {
                                If ((ACPF == One))
                                {
                                    Return (One)
                                }
                                Else
                                {
                                    Return (Zero)
                                }
                            }

                            Name (_PCL, Package (0x01)  // _PCL: Power Consumer List
                            {
                                PCI0
                            })
                        }
                    }
                }

                Scope (EC0)
                {
                    Method (_QA0, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
                    {
                        Sleep (0x01F4)
                        If (ACPS ())
                        {
                            ACPF = One
                            Local0 = 0x58
                        }
                        Else
                        {
                            ACPF = Zero
                            Local0 = 0x57
                        }

                        If (ATKP)
                        {
                            Notify (ATKD, Local0)
                        }

                        Notify (AC0, 0x80) // Status Change
                        Notify (BAT0, 0x80) // Status Change
                        Notify (\_PR.P001, 0x80) // Performance Capability Change
                        Notify (\_PR.P002, 0x80) // Performance Capability Change
                    }
                }

                Scope (\_SB)
                {
                    Device (LID)
                    {
                        Name (_HID, EisaId ("PNP0C0D") /* Lid Device */)  // _HID: Hardware ID
                        Method (_LID, 0, NotSerialized)  // _LID: Lid Status
                        {
                            Local0 = One
                            Local0 = ^^PCI0.SBRG.EC0.ST87 (Zero, 0x46)
                            If ((Local0 == Ones))
                            {
                                Local0 = One
                            }

                            Return (Local0)
                        }
                    }
                }

                Scope (EC0)
                {
                    Method (_Q80, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
                    {
                        Notify (LID, 0x80) // Status Change
                    }
                }

                Scope (\)
                {
                    Name (TSP, 0x0A)
                    Name (TC1, 0x02)
                    Name (TC2, 0x0A)
                }

                Scope (\_TZ)
                {
                    Method (KELV, 1, NotSerialized)
                    {
                        Local0 = (Arg0 & 0xFF)
                        If ((Local0 >= 0x80))
                        {
                            Local0 = (0x0100 - Local0)
                            Local0 *= 0x0A
                            Local0 = (0x0AAC - Local0)
                            Return (Local0)
                        }

                        Local0 *= 0x0A
                        Local0 += 0x0AAC
                        Return (Local0)
                    }

                    Method (CELC, 1, NotSerialized)
                    {
                        Local0 = (Arg0 - 0x0AAC)
                        Divide (Local0, 0x0A, Local1, Local0)
                        Return (Local0)
                    }

                    Name (PLCY, Zero)
                    ThermalZone (THRM)
                    {
                        Method (_CRT, 0, NotSerialized)  // _CRT: Critical Temperature
                        {
                            RCRT ()
                            Return (KELV (TCRT))
                        }

                        Method (_TMP, 0, NotSerialized)  // _TMP: Temperature
                        {
                            Local1 = 0x05
                            While (Local1)
                            {
                                Local0 = RTMP ()
                                If ((Local0 > TCRT))
                                {
                                    Local1--
                                }
                                Else
                                {
                                    Local1 = Zero
                                }
                            }

                            DBGR (0xDD, Local0)
                            Return (KELV (Local0))
                        }

                        Method (_PSL, 0, Serialized)  // _PSL: Passive List
                        {
                            Return (Package (0x02)
                            {
                                \_PR.P001, 
                                \_PR.P002
                            })
                        }

                        Method (_TSP, 0, NotSerialized)  // _TSP: Thermal Sampling Period
                        {
                            Local0 = (TSP * 0x0A)
                            Return (Local0)
                        }

                        Method (_TC1, 0, NotSerialized)  // _TC1: Thermal Constant 1
                        {
                            Return (TC1) /* \TC1_ */
                        }

                        Method (_TC2, 0, NotSerialized)  // _TC2: Thermal Constant 2
                        {
                            Return (TC2) /* \TC2_ */
                        }

                        Method (_PSV, 0, NotSerialized)  // _PSV: Passive Temperature
                        {
                            RPSV ()
                            Return (KELV (TPSV))
                        }

                        Method (_SCP, 1, NotSerialized)  // _SCP: Set Cooling Policy
                        {
                            PLCY = Zero
                            Notify (THRM, 0x81) // Thermal Trip Point Change
                        }
                    }
                }

                Scope (EC0)
                {
                    Method (_Q33, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
                    {
                        Notify (\_TZ.THRM, 0x80) // Thermal Status Change
                    }
                }

                Scope (\)
                {
                    Name (MNAM, "PEGATRON")
                }

                Scope (\_SB)
                {
                    Name (ATKP, Zero)
                    Device (ATKD)
                    {
                        Name (_HID, "ATK0100")  // _HID: Hardware ID
                        Name (_UID, 0x01010100)  // _UID: Unique ID
                        Method (INIT, 1, NotSerialized)
                        {
                            ATKP = One
                            Return (MNAM) /* \MNAM */
                        }

                        Method (SFUN, 0, NotSerialized)
                        {
                            EC6C = 0xC7
                            Local0 = 0x37
                        }

                        Method (WLED, 1, NotSerialized)
                        {
                            WRST = Arg0
                            OWLD (Arg0)
                        }

                        Method (BLED, 1, NotSerialized)
                        {
                            BRST = Arg0
                            OBTD (Arg0)
                        }

                        Method (RSTS, 0, NotSerialized)
                        {
                            Local0 = Zero
                            If (WRST)
                            {
                                Local0 |= One
                            }

                            If (BRST)
                            {
                                Local0 |= 0x02
                            }

                            Return (Local0)
                        }

                        Method (GLCD, 0, NotSerialized)
                        {
                            Return (LCDV) /* \LCDV */
                        }
                    }
                }

                Scope (^^ATKD)
                {
                    Method (EPSN, 0, NotSerialized)
                    {
                        Return (Zero)
                    }

                    Method (GPLV, 0, NotSerialized)
                    {
                        Return (LBTN) /* \LBTN */
                    }

                    Method (GAMA, 0, NotSerialized)
                    {
                        Name (AUOB, Buffer (0x0100)
                        {
                            /* 0000 */  0x00, 0x00, 0x00, 0x00, 0x01, 0x01, 0x01, 0x02,  // ........
                            /* 0008 */  0x02, 0x03, 0x04, 0x04, 0x04, 0x05, 0x05, 0x05,  // ........
                            /* 0010 */  0x06, 0x06, 0x07, 0x07, 0x08, 0x08, 0x09, 0x09,  // ........
                            /* 0018 */  0x09, 0x0A, 0x0B, 0x0B, 0x0C, 0x0C, 0x0D, 0x0D,  // ........
                            /* 0020 */  0x0E, 0x0F, 0x0F, 0x10, 0x11, 0x11, 0x12, 0x13,  // ........
                            /* 0028 */  0x14, 0x15, 0x15, 0x16, 0x17, 0x18, 0x18, 0x19,  // ........
                            /* 0030 */  0x1A, 0x1B, 0x1C, 0x1D, 0x1D, 0x1E, 0x1F, 0x20,  // ....... 
                            /* 0038 */  0x21, 0x22, 0x23, 0x24, 0x25, 0x26, 0x27, 0x28,  // !"#$%&'(
                            /* 0040 */  0x29, 0x2A, 0x2B, 0x2C, 0x2D, 0x2E, 0x2F, 0x30,  // )*+,-./0
                            /* 0048 */  0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38,  // 12345678
                            /* 0050 */  0x39, 0x3A, 0x3B, 0x3D, 0x3E, 0x3F, 0x40, 0x41,  // 9:;=>?@A
                            /* 0058 */  0x42, 0x43, 0x43, 0x44, 0x45, 0x46, 0x47, 0x48,  // BCCDEFGH
                            /* 0060 */  0x49, 0x4A, 0x4B, 0x4C, 0x4D, 0x4F, 0x50, 0x51,  // IJKLMOPQ
                            /* 0068 */  0x52, 0x53, 0x54, 0x55, 0x56, 0x57, 0x58, 0x59,  // RSTUVWXY
                            /* 0070 */  0x5A, 0x5B, 0x5C, 0x5D, 0x5E, 0x5F, 0x60, 0x61,  // Z[\]^_`a
                            /* 0078 */  0x62, 0x63, 0x64, 0x65, 0x66, 0x67, 0x68, 0x69,  // bcdefghi
                            /* 0080 */  0x6A, 0x6B, 0x6C, 0x6D, 0x6F, 0x70, 0x71, 0x72,  // jklmopqr
                            /* 0088 */  0x73, 0x74, 0x75, 0x76, 0x77, 0x78, 0x79, 0x7A,  // stuvwxyz
                            /* 0090 */  0x7B, 0x7D, 0x7E, 0x7F, 0x80, 0x81, 0x82, 0x83,  // {}~.....
                            /* 0098 */  0x84, 0x85, 0x86, 0x87, 0x88, 0x89, 0x8A, 0x8B,  // ........
                            /* 00A0 */  0x8C, 0x8D, 0x8E, 0x8F, 0x91, 0x92, 0x93, 0x94,  // ........
                            /* 00A8 */  0x95, 0x96, 0x97, 0x98, 0x99, 0x9A, 0x9B, 0x9C,  // ........
                            /* 00B0 */  0x9D, 0x9E, 0xA0, 0xA1, 0xA2, 0xA3, 0xA4, 0xA5,  // ........
                            /* 00B8 */  0xA6, 0xA7, 0xA9, 0xAA, 0xAB, 0xAC, 0xAD, 0xAE,  // ........
                            /* 00C0 */  0xAF, 0xB1, 0xB2, 0xB3, 0xB4, 0xB5, 0xB6, 0xB7,  // ........
                            /* 00C8 */  0xB9, 0xBA, 0xBB, 0xBC, 0xBD, 0xBF, 0xC0, 0xC1,  // ........
                            /* 00D0 */  0xC2, 0xC4, 0xC5, 0xC6, 0xC7, 0xC8, 0xCA, 0xCB,  // ........
                            /* 00D8 */  0xCC, 0xCD, 0xCE, 0xD0, 0xD1, 0xD2, 0xD3, 0xD5,  // ........
                            /* 00E0 */  0xD6, 0xD7, 0xD8, 0xDA, 0xDB, 0xDC, 0xDD, 0xDF,  // ........
                            /* 00E8 */  0xE0, 0xE1, 0xE3, 0xE4, 0xE5, 0xE6, 0xE8, 0xE9,  // ........
                            /* 00F0 */  0xEA, 0xEC, 0xED, 0xEE, 0xEF, 0xF1, 0xF2, 0xF3,  // ........
                            /* 00F8 */  0xF4, 0xF6, 0xF7, 0xF8, 0xFA, 0xFC, 0xFE, 0xFF   // ........
                        })
                        WBYT (0x70, 0x4F, 0x06)
                        Local2 = Zero
                        While ((Local2 != 0xFF))
                        {
                            DBG8 = Zero
                            WBYT (0x70, 0x50, DerefOf (AUOB [Local2]))
                            Local2++
                            DBG8 = One
                        }

                        Local2 = Zero
                        While ((Local2 != 0xFF))
                        {
                            DBG8 = 0x02
                            WBYT (0x70, 0x51, DerefOf (AUOB [Local2]))
                            Local2++
                            DBG8 = 0x03
                        }

                        Local2 = Zero
                        While ((Local2 != 0xFF))
                        {
                            DBG8 = 0x04
                            WBYT (0x70, 0x52, DerefOf (AUOB [Local2]))
                            Local2++
                            DBG8 = 0x05
                        }

                        Local2 = Zero
                        While ((Local2 != 0xFF))
                        {
                            DBG8 = 0x06
                            WBYT (0x70, 0x53, DerefOf (AUOB [Local2]))
                            Local2++
                            DBG8 = 0x07
                        }

                        WBYT (0x70, 0x4F, One)
                        Notify (ATKD, 0xD7) // Hardware-Specific
                        Return (Zero)
                    }

                    Method (SPGS, 1, NotSerialized)
                    {
                        If (((Arg0 == 0x02) | (Arg0 == 0x09)))
                        {
                            PMOD = One
                        }
                        Else
                        {
                            PMOD = Zero
                        }

                        Notify (\_PR.P001, 0x80) // Performance Capability Change
                        Notify (\_PR.P002, 0x80) // Performance Capability Change
                        Return (One)
                    }

                    Method (GVVI, 0, NotSerialized)
                    {
                        Local0 = RBYT (0x71, Zero)
                        Local1 = (Local0 & 0xFF)
                        If ((Local1 != 0xFF))
                        {
                            Return (One)
                        }
                        Else
                        {
                            Return (Zero)
                        }
                    }

                    Method (OSVR, 1, NotSerialized)
                    {
                        OSTY = Arg0
                        Return (OSTY) /* \OSTY */
                    }

                    Method (OLED, 1, NotSerialized)
                    {
                        If ((Arg0 == One))
                        {
                            If ((Arg0 != BTDP))
                            {
                                SGPL (0x08, One, One)
                            }
                            ElseIf ((Arg0 != BRST))
                            {
                                SGPL (0x08, One, One)
                            }

                            WLRF = One
                        }

                        If ((Arg0 == Zero))
                        {
                            If ((Arg0 == BTDP))
                            {
                                SGPL (0x08, One, Zero)
                            }
                            ElseIf ((Arg0 == BRST))
                            {
                                SGPL (0x08, One, Zero)
                            }

                            WLRF = Zero
                        }
                    }

                    Method (AGFN, 1, Serialized)
                    {
                        If ((Arg0 == Zero))
                        {
                            Return (GNBF) /* \GNBF */
                        }

                        Local0 = Zero
                        OperationRegion (\PARM, SystemMemory, Arg0, 0x08)
                        Field (PARM, DWordAcc, NoLock, Preserve)
                        {
                            MFUN,   16, 
                            SFUN,   16, 
                            LEN,    16, 
                            STAS,   8, 
                            EROR,   8
                        }

                        EROR = Zero
                        STAS = One
                        If ((MFUN == One))
                        {
                            GVER (Arg0, LEN)
                            STAS &= 0xFE
                        }

                        If ((MFUN == 0x30))
                        {
                            MF30 (Arg0, SFUN, LEN)
                            STAS &= 0xFE
                        }

                        If ((MFUN == 0x41))
                        {
                            MF41 (Arg0, SFUN, LEN)
                            STAS &= 0xFE
                        }

                        If ((STAS == One))
                        {
                            EROR = One
                            STAS |= 0x02
                        }

                        STAS &= 0xFE
                        STAS |= 0x80
                        Return (Zero)
                    }

                    Method (GVER, 2, NotSerialized)
                    {
                        OperationRegion (\FGVR, SystemMemory, Arg0, Arg1)
                        Field (FGVR, DWordAcc, NoLock, Preserve)
                        {
                            Offset (0x08), 
                            APID,   16, 
                            APRV,   32
                        }

                        Return (Zero)
                    }

                    Method (MF30, 3, NotSerialized)
                    {
                        OperationRegion (FM30, SystemMemory, Arg0, 0x08)
                        Field (FM30, DWordAcc, NoLock, Preserve)
                        {
                            Offset (0x06), 
                            SM30,   8, 
                            EM30,   8
                        }

                        Local0 = One
                        If ((Arg1 == Zero))
                        {
                            Local0 = G30V (Arg0, Arg2)
                        }

                        If ((Arg1 == One))
                        {
                            Local0 = EC01 (Arg0, Arg2)
                        }

                        If ((Arg1 == 0x02))
                        {
                            Local0 = EC02 (Arg0, Arg2)
                        }

                        If (Local0)
                        {
                            EM30 = Local0
                            SM30 |= 0x02
                        }

                        SM30 |= 0x80
                        Return (Zero)
                    }

                    Method (G30V, 2, NotSerialized)
                    {
                        If ((Arg1 < 0x0C))
                        {
                            Return (0x02)
                        }

                        OperationRegion (\F300, SystemMemory, Arg0, Arg1)
                        Field (F300, DWordAcc, NoLock, Preserve)
                        {
                            Offset (0x08), 
                            SVER,   16, 
                            MVER,   16
                        }

                        MVER = Zero
                        SVER = Zero
                        Return (Zero)
                    }

                    Method (EC01, 2, NotSerialized)
                    {
                        If ((Arg1 < 0x10))
                        {
                            Return (0x02)
                        }

                        OperationRegion (FEC1, SystemMemory, Arg0, Arg1)
                        Field (FEC1, DWordAcc, NoLock, Preserve)
                        {
                            Offset (0x08), 
                            ECMD,   8, 
                            EDA1,   8, 
                            EDA2,   8, 
                            EDA3,   8, 
                            EDA4,   8, 
                            EDA5,   8
                        }

                        Local0 = ^^PCI0.SBRG.EC0.ECXT (ECMD, EDA1, EDA2, EDA3, EDA4, EDA5)
                        EDA1 = DerefOf (Local0 [One])
                        EDA2 = DerefOf (Local0 [0x02])
                        EDA3 = DerefOf (Local0 [0x03])
                        EDA4 = DerefOf (Local0 [0x04])
                        EDA5 = DerefOf (Local0 [0x05])
                        Return (DerefOf (Local0 [Zero]))
                    }

                    Method (EC02, 2, NotSerialized)
                    {
                        If ((Arg1 < 0x30))
                        {
                            Return (0x02)
                        }

                        OperationRegion (FEC2, SystemMemory, Arg0, Arg1)
                        Field (FEC2, DWordAcc, NoLock, Preserve)
                        {
                            Offset (0x08), 
                            BUSN,   8, 
                            PROT,   8, 
                            DADD,   8, 
                            DREG,   8, 
                            DAT0,   8, 
                            DAT1,   8, 
                            BLEN,   8, 
                            REVB,   8, 
                            BLK1,   32, 
                            BLK2,   32, 
                            BLK3,   32, 
                            BLK4,   32, 
                            BLK5,   32, 
                            BLK6,   32, 
                            BLK7,   32, 
                            BLK8,   32
                        }

                        Local0 = ^^PCI0.SBRG.EC0.ECSB (BUSN, PROT, DADD, DREG, DAT0, DAT1)
                        DAT0 = DerefOf (Local0 [One])
                        DAT1 = DerefOf (Local0 [0x02])
                        BLEN = DerefOf (Local0 [0x03])
                        Name (BKUF, Buffer (0x20){})
                        CreateDWordField (BKUF, Zero, DD01)
                        CreateDWordField (BKUF, 0x04, DD02)
                        CreateDWordField (BKUF, 0x08, DD03)
                        CreateDWordField (BKUF, 0x0C, DD04)
                        CreateDWordField (BKUF, 0x10, DD05)
                        CreateDWordField (BKUF, 0x14, DD06)
                        CreateDWordField (BKUF, 0x18, DD07)
                        CreateDWordField (BKUF, 0x1C, DD08)
                        BKUF = DerefOf (Local0 [0x04])
                        BLK1 = DD01 /* \_SB_.ATKD.EC02.DD01 */
                        BLK2 = DD02 /* \_SB_.ATKD.EC02.DD02 */
                        BLK3 = DD03 /* \_SB_.ATKD.EC02.DD03 */
                        BLK4 = DD04 /* \_SB_.ATKD.EC02.DD04 */
                        BLK5 = DD05 /* \_SB_.ATKD.EC02.DD05 */
                        BLK6 = DD06 /* \_SB_.ATKD.EC02.DD06 */
                        BLK7 = DD07 /* \_SB_.ATKD.EC02.DD07 */
                        BLK8 = DD08 /* \_SB_.ATKD.EC02.DD08 */
                        Local2 = DerefOf (Local0 [Zero])
                        Local2 &= 0x3F
                        Return (Local2)
                    }

                    Method (GENW, 1, NotSerialized)
                    {
                    }

                    Method (MF41, 3, NotSerialized)
                    {
                        Name (SF41, Zero)
                        OperationRegion (FM41, SystemMemory, Arg0, 0x08)
                        Field (FM41, DWordAcc, NoLock, Preserve)
                        {
                            Offset (0x06), 
                            SM41,   8, 
                            EM41,   8
                        }

                        Local0 = One
                        SF41 = Arg1
                        Name (TTT0, Zero)
                        TTT0 = SF41 /* \_SB_.ATKD.MF41.SF41 */
                        If ((TTT0 == 0x03))
                        {
                            Local0 = M413 (Arg0, Arg2)
                        }
                        ElseIf ((TTT0 == 0x04))
                        {
                            Local0 = M414 (Arg0, Arg2)
                        }

                        If (Local0)
                        {
                            EM41 = Local0
                            SM41 |= 0x02
                        }

                        SM41 |= 0x80
                        Return (Zero)
                    }

                    Method (G41V, 2, NotSerialized)
                    {
                        If ((Arg1 < 0x0C))
                        {
                            Return (0x02)
                        }

                        OperationRegion (\F410, SystemMemory, Arg0, Arg1)
                        Field (F410, DWordAcc, NoLock, Preserve)
                        {
                            Offset (0x08), 
                            SVER,   16, 
                            MVER,   16
                        }

                        MVER = Zero
                        SVER = Zero
                        Return (Zero)
                    }

                    Method (M413, 2, NotSerialized)
                    {
                        If ((Arg1 < 0x15))
                        {
                            Return (0x02)
                        }

                        OperationRegion (F413, SystemMemory, Arg0, Arg1)
                        Field (F413, DWordAcc, NoLock, Preserve)
                        {
                            Offset (0x08), 
                            BYT0,   8, 
                            BYT1,   8, 
                            BYT2,   8, 
                            BYT3,   8, 
                            BYT4,   8, 
                            BYT5,   8, 
                            BYT6,   8, 
                            BYT7,   8, 
                            BYT8,   8, 
                            BYT9,   8, 
                            BYTA,   8, 
                            BYTB,   8, 
                            BYTC,   8
                        }

                        BYT0 = Zero
                        BYT1 = Zero
                        BYT2 = Zero
                        BYT3 = Zero
                        BYT4 = Zero
                        BYT5 = Zero
                        BYT6 = Zero
                        BYT7 = Zero
                        BYT8 = 0x12
                        BYT9 = Zero
                        BYTA = Zero
                        BYTB = Zero
                        BYTC = Zero
                        Return (Zero)
                    }

                    Method (M414, 2, NotSerialized)
                    {
                        If ((Arg1 < 0x09))
                        {
                            Return (0x02)
                        }

                        OperationRegion (F414, SystemMemory, Arg0, Arg1)
                        Field (F414, DWordAcc, NoLock, Preserve)
                        {
                            Offset (0x08), 
                            ATST,   8
                        }

                        If ((ATST == One))
                        {
                            ^^PCI0.SBRG.EC0.SPIN (0x19, Zero)
                        }
                        ElseIf ((ATST == 0x04))
                        {
                            ^^PCI0.SBRG.EC0.SPIN (0x19, One)
                        }

                        Return (Zero)
                    }

                    Method (WONF, 0, NotSerialized)
                    {
                        Return (Zero)
                    }
                }

                Method (SDSP, 1, NotSerialized)
                {
                    Notify (VGA, 0x80) // Status Change
                }

                Scope (EC0)
                {
                    Method (_Q0E, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
                    {
                        Local0 = ^^^VGA.GCDD ()
                        If ((Local0 != One))
                        {
                            If ((LBTN > Zero))
                            {
                                LBTN--
                            }

                            If ((LBTN > 0x0F))
                            {
                                LBTN = 0x0F
                            }

                            If ((ACPF == One))
                            {
                                Local0 = DerefOf (PWAC [LBTN])
                            }

                            If ((ACPF == Zero))
                            {
                                Local0 = DerefOf (PWDC [LBTN])
                            }

                            WBOV (Zero, Local0)
                            If (ATKP)
                            {
                                Notify (ATKD, (LBTN + 0x20))
                            }

                            Notify (^^^VGA.LCDD, 0x87) // Device-Specific
                            Sleep (0x14)
                        }
                    }

                    Method (_Q0F, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
                    {
                        Local0 = ^^^VGA.GCDD ()
                        If ((Local0 != One))
                        {
                            If ((LBTN < 0x0F))
                            {
                                LBTN++
                            }
                            Else
                            {
                                LBTN = 0x0F
                            }

                            If ((ACPF == One))
                            {
                                Local0 = DerefOf (PWAC [LBTN])
                            }

                            If ((ACPF == Zero))
                            {
                                Local0 = DerefOf (PWDC [LBTN])
                            }

                            WBOV (Zero, Local0)
                            If (ATKP)
                            {
                                Notify (ATKD, (LBTN + 0x10))
                            }

                            Notify (^^^VGA.LCDD, 0x86) // Device-Specific
                            Sleep (0x14)
                        }
                    }
                }

                Scope (\)
                {
                    Name (PWAC, Buffer (0x10)
                    {
                        /* 0000 */  0x08, 0x19, 0x29, 0x3A, 0x4A, 0x5B, 0x6B, 0x7C,  // ..):J[k|
                        /* 0008 */  0x8C, 0x9D, 0xAD, 0xBE, 0xCE, 0xDF, 0xEF, 0xFF   // ........
                    })
                    Name (PWDC, Buffer (0x10)
                    {
                        /* 0000 */  0x08, 0x15, 0x23, 0x30, 0x3E, 0x4B, 0x59, 0x66,  // ..#0>KYf
                        /* 0008 */  0x74, 0x81, 0x8F, 0x9C, 0xAA, 0xB7, 0xC5, 0xCF   // t.......
                    })
                }

                Scope (EC0)
                {
                    Method (_Q10, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
                    {
                        Local0 = One
                        Local0 = ST87 (Zero, 0x35)
                        Local0 ^= One
                        If (Local0)
                        {
                            ST87 (0x20, 0x35)
                        }
                        Else
                        {
                            ST87 (0x40, 0x35)
                        }

                        If (ATKP)
                        {
                            Local0 = (0x34 - Local0)
                            Notify (ATKD, Local0)
                        }
                    }
                }

                Scope (EC0)
                {
                    Method (_Q0B, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
                    {
                        If ((OSTY == 0x40))
                        {
                            If ((WLDP && BTDP))
                            {
                                If ((RGPO (0x06) == One))
                                {
                                    SGPL (0x06, One, Zero)
                                    WRPS = One
                                }

                                Local0 = WLRF /* \WLRF */
                                Local0 |= (BRST << One)
                                Local0++
                                If ((Local0 > 0x03))
                                {
                                    Local0 = Zero
                                }

                                Local1 = DerefOf (WBTL [Local0])
                                Name (TTT0, Zero)
                                TTT0 = Local1
                                If ((TTT0 == Zero))
                                {
                                    Notify (ATKD, 0x5F) // Reserved
                                    WLRF = Zero
                                    Sleep (0x0DAC)
                                    OBTD (Zero)
                                    Notify (ATKD, 0x7E) // Reserved
                                    SGPL (0x08, One, Zero)
                                }
                                ElseIf ((TTT0 == One))
                                {
                                    Notify (ATKD, 0x5E) // Reserved
                                    WLRF = One
                                    Sleep (0x0DAC)
                                    OBTD (Zero)
                                    Notify (ATKD, 0x7E) // Reserved
                                    SGPL (0x08, One, One)
                                }
                                ElseIf ((TTT0 == 0x02))
                                {
                                    Notify (ATKD, 0x5F) // Reserved
                                    WLRF = Zero
                                    Sleep (0x0DAC)
                                    OBTD (One)
                                    Notify (ATKD, 0x7D) // Reserved
                                }
                                ElseIf ((TTT0 == 0x03))
                                {
                                    Notify (ATKD, 0x5E) // Reserved
                                    WLRF = One
                                    Sleep (0x0DAC)
                                    OBTD (One)
                                    Notify (ATKD, 0x7D) // Reserved
                                }
                            }
                            ElseIf (WLDP)
                            {
                                If ((RGPO (0x06) == One))
                                {
                                    SGPL (0x06, One, Zero)
                                }

                                If (RGPO (0x08))
                                {
                                    Notify (ATKD, 0x5F) // Reserved
                                    SGPL (0x08, One, Zero)
                                    SGPL (0x26, One, One)
                                    WLRF = Zero
                                }
                                Else
                                {
                                    Notify (ATKD, 0x5E) // Reserved
                                    SGPL (0x08, One, One)
                                    SGPL (0x26, One, Zero)
                                    WLRF = One
                                }
                            }
                            ElseIf (BTDP)
                            {
                                If (BRST)
                                {
                                    OBTD (Zero)
                                    Notify (ATKD, 0x7E) // Reserved
                                    SGPL (0x08, One, Zero)
                                }
                                Else
                                {
                                    OBTD (One)
                                    Notify (ATKD, 0x7D) // Reserved
                                    SGPL (0x08, One, One)
                                }
                            }
                        }

                        If ((OSTY == 0x10))
                        {
                            If ((WLDP && BTDP))
                            {
                                Local0 = WRST /* \WRST */
                                Local0 |= (BRST << One)
                                Local0++
                                If ((Local0 > 0x03))
                                {
                                    Local0 = Zero
                                }

                                Local1 = DerefOf (WBTL [Local0])
                                Name (TTT1, Zero)
                                TTT1 = Local1
                                If ((TTT1 == Zero))
                                {
                                    OWLD (Zero)
                                    Notify (ATKD, 0x5F) // Reserved
                                    Sleep (0x0DAC)
                                    OBTD (Zero)
                                    Notify (ATKD, 0x7E) // Reserved
                                    SGPL (0x08, One, Zero)
                                }
                                ElseIf ((TTT1 == One))
                                {
                                    OWLD (One)
                                    Notify (ATKD, 0x5E) // Reserved
                                    Sleep (0x0DAC)
                                    OBTD (Zero)
                                    Notify (ATKD, 0x7E) // Reserved
                                }
                                ElseIf ((TTT1 == 0x02))
                                {
                                    OWLD (Zero)
                                    Notify (ATKD, 0x5F) // Reserved
                                    Sleep (0x0DAC)
                                    OBTD (One)
                                    Notify (ATKD, 0x7D) // Reserved
                                }
                                ElseIf ((TTT1 == 0x03))
                                {
                                    OWLD (One)
                                    Notify (ATKD, 0x5E) // Reserved
                                    Sleep (0x0DAC)
                                    OBTD (One)
                                    Notify (ATKD, 0x7D) // Reserved
                                }
                            }
                            ElseIf (WLDP)
                            {
                                If (WRST)
                                {
                                    OWLD (Zero)
                                    Notify (ATKD, 0x5F) // Reserved
                                    SGPL (0x08, One, Zero)
                                }
                                Else
                                {
                                    OWLD (One)
                                    Notify (ATKD, 0x5E) // Reserved
                                    SGPL (0x08, One, One)
                                }
                            }
                            ElseIf (BTDP)
                            {
                                If (BRST)
                                {
                                    OBTD (Zero)
                                    Notify (ATKD, 0x7E) // Reserved
                                    SGPL (0x08, One, Zero)
                                }
                                Else
                                {
                                    OBTD (One)
                                    Notify (ATKD, 0x7D) // Reserved
                                    SGPL (0x08, One, One)
                                }
                            }
                        }

                        If (((OSTY != 0x10) && (OSTY != 0x40)))
                        {
                            If ((WLDP && BTDP))
                            {
                                If ((RGPO (0x06) == One))
                                {
                                    SGPL (0x06, One, Zero)
                                    WRPS = One
                                }

                                Local0 = WLRF /* \WLRF */
                                Local0 |= (BRST << One)
                                Local0++
                                If ((Local0 > 0x03))
                                {
                                    Local0 = Zero
                                }

                                Local1 = DerefOf (WBTL [Local0])
                                Name (TTT2, Zero)
                                TTT2 = Local1
                                If ((TTT2 == Zero))
                                {
                                    Notify (ATKD, 0x5F) // Reserved
                                    WLRF = Zero
                                    Sleep (0x0DAC)
                                    OBTD (Zero)
                                    Notify (ATKD, 0x7E) // Reserved
                                    SGPL (0x08, One, Zero)
                                }
                                ElseIf ((TTT2 == One))
                                {
                                    Notify (ATKD, 0x5E) // Reserved
                                    WLRF = One
                                    Sleep (0x0DAC)
                                    OBTD (Zero)
                                    Notify (ATKD, 0x7E) // Reserved
                                    SGPL (0x08, One, One)
                                }
                                ElseIf ((TTT2 == 0x02))
                                {
                                    Notify (ATKD, 0x5F) // Reserved
                                    WLRF = Zero
                                    Sleep (0x0DAC)
                                    OBTD (One)
                                    Notify (ATKD, 0x7D) // Reserved
                                }
                                ElseIf ((TTT2 == 0x03))
                                {
                                    Notify (ATKD, 0x5E) // Reserved
                                    WLRF = One
                                    Sleep (0x0DAC)
                                    OBTD (One)
                                    Notify (ATKD, 0x7D) // Reserved
                                }
                            }
                            ElseIf (WLDP)
                            {
                                If ((RGPO (0x06) == One))
                                {
                                    SGPL (0x06, One, Zero)
                                }

                                If (RGPO (0x08))
                                {
                                    Notify (ATKD, 0x5F) // Reserved
                                    SGPL (0x08, One, Zero)
                                    SGPL (0x26, One, One)
                                    WLRF = Zero
                                }
                                Else
                                {
                                    Notify (ATKD, 0x5E) // Reserved
                                    SGPL (0x08, One, One)
                                    SGPL (0x26, One, Zero)
                                    WLRF = One
                                }
                            }
                            ElseIf (BTDP)
                            {
                                If (BRST)
                                {
                                    OBTD (Zero)
                                    Notify (ATKD, 0x7E) // Reserved
                                    SGPL (0x08, One, Zero)
                                }
                                Else
                                {
                                    OBTD (One)
                                    Notify (ATKD, 0x7D) // Reserved
                                    SGPL (0x08, One, One)
                                }
                            }
                        }
                    }

                    Name (WBTL, Package (0x04)
                    {
                        Zero, 
                        One, 
                        0x02, 
                        0x03
                    })
                }

                Scope (\)
                {
                    Method (OBTD, 1, Serialized)
                    {
                        BRST = Arg0
                        If ((Arg0 == One))
                        {
                            SGPL (0x1A, One, One)
                            SGPL (0x24, One, One)
                            SGPL (0x08, One, One)
                        }
                        Else
                        {
                            SGPL (0x1A, One, Zero)
                            SGPL (0x24, One, Zero)
                        }
                    }

                    Method (OWLD, 1, Serialized)
                    {
                        WRST = Arg0
                        If ((Arg0 == One))
                        {
                            SGPL (0x26, One, Zero)
                            SGPL (0x08, One, One)
                            SGPL (0x06, One, Zero)
                        }
                        Else
                        {
                            SGPL (0x26, One, One)
                            SGPL (0x06, One, One)
                        }
                    }
                }

                Scope (\)
                {
                    OperationRegion (GPIO, SystemIO, GPBS, 0x40)
                    Field (GPIO, ByteAcc, NoLock, Preserve)
                    {
                        Offset (0x0C), 
                        GL00,   16, 
                        GL10,   16, 
                        Offset (0x18), 
                        GB00,   32, 
                        Offset (0x2C), 
                        GP00,   16, 
                        Offset (0x38), 
                        GL20,   32
                    }

                    Method (SGPL, 3, Serialized)
                    {
                        Local0 = Arg1
                        Local1 = Zero
                        While (Local0)
                        {
                            Local1 <<= One
                            Local1 |= One
                            Local0--
                        }

                        If ((Arg0 >= 0x10))
                        {
                            If ((Arg0 < 0x20))
                            {
                                Local0 = GL10 /* \GL10 */
                                Local2 = (Arg0 - 0x10)
                            }
                            Else
                            {
                                Local0 = GL20 /* \GL20 */
                                Local2 = (Arg0 - 0x20)
                            }

                            Local1 <<= Local2
                            Local3 = ~Local1
                            Local0 &= Local3
                            Local4 = (Arg2 << Local2)
                            Local0 |= Local4
                            If ((Arg0 < 0x20))
                            {
                                GL10 = Local0
                            }
                            Else
                            {
                                GL20 = Local0
                            }
                        }
                        Else
                        {
                            Local1 <<= Arg0
                            Local3 = ~Local1
                            Local0 = (GL00 & Local3)
                            Local4 = (Arg2 << Arg0)
                            Local0 |= Local4
                            GL00 = Local0
                        }
                    }

                    Method (RGPP, 1, Serialized)
                    {
                        Local0 = (GP00 >> Arg0)
                        Local0 &= One
                        Return (Local0)
                    }

                    Method (TGPP, 1, Serialized)
                    {
                        Local0 = (One << Arg0)
                        GP00 ^= Local0
                    }

                    Method (SGPP, 2, Serialized)
                    {
                        Local0 = (One << Arg0)
                        If (Arg1)
                        {
                            GP00 |= Local0
                        }
                        Else
                        {
                            Local1 = ~Local0
                            GP00 &= Local1
                        }
                    }

                    Method (RGPO, 1, Serialized)
                    {
                        If ((Arg0 >= 0x20))
                        {
                            Local0 = (GL20 >> Arg0 -= 0x20)
                            Local0 &= One
                            Return (Local0)
                        }
                        ElseIf ((Arg0 >= 0x10))
                        {
                            Local0 = (GL10 >> Arg0 -= 0x10)
                            Local0 &= One
                            Return (Local0)
                        }
                        Else
                        {
                            Local0 = (GL00 >> Arg0)
                            Local0 &= One
                            Return (Local0)
                        }
                    }
                }

                Scope (EC0)
                {
                    Name (AVNC, Package (0x0C)
                    {
                        Zero, 
                        0x61, 
                        0x62, 
                        0x63, 
                        Zero, 
                        Zero, 
                        Zero, 
                        Zero, 
                        0xA0, 
                        0xA1, 
                        0xA2, 
                        Zero
                    })
                    Method (ADVG, 0, NotSerialized)
                    {
                        If (^^^VGA.PRST ())
                        {
                            Return (^^^VGA.ADVD ())
                        }

                        Return (0x03)
                    }

                    Method (_Q11, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
                    {
                        FHKW ()
                        Local0 = ADVG ()
                        If (NATK ())
                        {
                            Local1 = DerefOf (AVNC [Local0])
                            If (ATKP)
                            {
                                Notify (ATKD, Local1)
                            }
                            Else
                            {
                                SWHG (Local0)
                            }
                        }
                        Else
                        {
                            SWHG (Local0)
                        }

                        FHKS ()
                    }

                    Name (FHKM, One)
                    Method (FHKW, 0, Serialized)
                    {
                        While (!FHKM)
                        {
                            Sleep (0x0A)
                        }

                        FHKM = Zero
                    }

                    Method (FHKS, 0, Serialized)
                    {
                        FHKM = One
                    }
                }

                Scope (\)
                {
                    Method (SWHG, 1, Serialized)
                    {
                        If (\_SB.PCI0.VGA.PRST ())
                        {
                            \_SB.PCI0.VGA.SWHD (Arg0)
                            Return (One)
                        }

                        Return (Zero)
                    }

                    Method (NATK, 0, NotSerialized)
                    {
                        If (\_SB.PCI0.VGA.PRST ())
                        {
                            Return (\_SB.PCI0.VGA.NATK ())
                        }

                        Return (One)
                    }
                }

                Scope (EC0)
                {
                    Method (_Q99, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
                    {
                    }

                    Method (_Q0A, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
                    {
                        Notify (SLPB, 0x80) // Status Change
                    }

                    Method (_Q0C, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
                    {
                        If (ATKP)
                        {
                            Notify (ATKD, 0x50) // Reserved
                            DBG8 = 0x50
                        }
                    }

                    Method (_Q0D, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
                    {
                        If (ATKP)
                        {
                            Notify (ATKD, 0x51) // Reserved
                            DBG8 = 0x51
                        }
                    }

                    Method (_Q12, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
                    {
                        If (ATKP)
                        {
                            Notify (ATKD, 0x6B) // Reserved
                        }
                    }

                    Method (_Q13, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
                    {
                        If (ATKP)
                        {
                            Notify (ATKD, 0x32) // Reserved
                        }
                    }

                    Method (_Q14, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
                    {
                        If ((AVOL < 0x0F))
                        {
                            AVOL++
                        }

                        If (ATKP)
                        {
                            Notify (ATKD, 0x31) // Reserved
                        }
                    }

                    Method (_Q15, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
                    {
                        If ((AVOL > Zero))
                        {
                            AVOL--
                        }

                        If (ATKP)
                        {
                            Notify (ATKD, 0x30) // Reserved
                        }
                    }
                }
            }

            Device (IDE1)
            {
                Name (_ADR, 0x001F0002)  // _ADR: Address
                Name (\FZTF, Buffer (0x07)
                {
                     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xF5         // .......
                })
                Name (REGF, One)
                Method (_REG, 2, NotSerialized)  // _REG: Region Availability
                {
                    If ((Arg0 == 0x02))
                    {
                        REGF = Arg1
                    }
                }

                Name (TIM0, Package (0x08)
                {
                    Package (0x04)
                    {
                        0x78, 
                        0xB4, 
                        0xF0, 
                        0x0384
                    }, 

                    Package (0x04)
                    {
                        0x23, 
                        0x21, 
                        0x10, 
                        Zero
                    }, 

                    Package (0x04)
                    {
                        0x0B, 
                        0x09, 
                        0x04, 
                        Zero
                    }, 

                    Package (0x06)
                    {
                        0x78, 
                        0x5A, 
                        0x3C, 
                        0x28, 
                        0x1E, 
                        0x14
                    }, 

                    Package (0x06)
                    {
                        Zero, 
                        One, 
                        0x02, 
                        One, 
                        0x02, 
                        One
                    }, 

                    Package (0x06)
                    {
                        Zero, 
                        Zero, 
                        Zero, 
                        One, 
                        One, 
                        One
                    }, 

                    Package (0x04)
                    {
                        0x04, 
                        0x03, 
                        0x02, 
                        Zero
                    }, 

                    Package (0x04)
                    {
                        0x02, 
                        One, 
                        Zero, 
                        Zero
                    }
                })
                Name (TMD0, Buffer (0x14){})
                CreateDWordField (TMD0, Zero, PIO0)
                CreateDWordField (TMD0, 0x04, DMA0)
                CreateDWordField (TMD0, 0x08, PIO1)
                CreateDWordField (TMD0, 0x0C, DMA1)
                CreateDWordField (TMD0, 0x10, CHNF)
                OperationRegion (CFG2, PCI_Config, 0x40, 0x20)
                Field (CFG2, DWordAcc, NoLock, Preserve)
                {
                    PMPT,   4, 
                    PSPT,   4, 
                    PMRI,   6, 
                    Offset (0x02), 
                    SMPT,   4, 
                    SSPT,   4, 
                    SMRI,   6, 
                    Offset (0x04), 
                    PSRI,   4, 
                    SSRI,   4, 
                    Offset (0x08), 
                    PM3E,   1, 
                    PS3E,   1, 
                    SM3E,   1, 
                    SS3E,   1, 
                    Offset (0x0A), 
                    PMUT,   2, 
                        ,   2, 
                    PSUT,   2, 
                    Offset (0x0B), 
                    SMUT,   2, 
                        ,   2, 
                    SSUT,   2, 
                    Offset (0x0C), 
                    Offset (0x14), 
                    PM6E,   1, 
                    PS6E,   1, 
                    SM6E,   1, 
                    SS6E,   1, 
                    PMCR,   1, 
                    PSCR,   1, 
                    SMCR,   1, 
                    SSCR,   1, 
                        ,   4, 
                    PMAE,   1, 
                    PSAE,   1, 
                    SMAE,   1, 
                    SSAE,   1
                }

                Name (GMPT, Zero)
                Name (GMUE, Zero)
                Name (GMUT, Zero)
                Name (GMCR, Zero)
                Name (GSPT, Zero)
                Name (GSUE, Zero)
                Name (GSUT, Zero)
                Name (GSCR, Zero)
                Device (CHN0)
                {
                    Name (_ADR, Zero)  // _ADR: Address
                    Method (_GTM, 0, NotSerialized)  // _GTM: Get Timing Mode
                    {
                        Local1 = (PSCR << One)
                        Local0 = (PMCR | Local1)
                        Local3 = (PMAE << 0x02)
                        Local4 = (PM6E << One)
                        Local3 |= Local4
                        Local1 = (PM3E | Local3)
                        Local3 = (PMPT << 0x04)
                        Local1 |= Local3
                        Local3 = (PSAE << 0x02)
                        Local4 = (PS6E << One)
                        Local3 |= Local4
                        Local2 = (PS3E | Local3)
                        Local3 = (PSPT << 0x04)
                        Local2 |= Local3
                        Return (GTM (PMRI, Local1, PMUT, PSRI, Local2, PSUT, Local0))
                    }

                    Method (_STM, 3, NotSerialized)  // _STM: Set Timing Mode
                    {
                        Debug = Arg0
                        TMD0 = Arg0
                        Local3 = (PMAE << 0x02)
                        Local4 = (PM6E << One)
                        Local3 |= Local4
                        Local0 = (PM3E | Local3)
                        Local3 = (PMPT << 0x04)
                        Local0 |= Local3
                        Local3 = (PSAE << 0x02)
                        Local4 = (PS6E << One)
                        Local3 |= Local4
                        Local1 = (PS3E | Local3)
                        Local3 = (PSPT << 0x04)
                        Local1 |= Local3
                        GMPT = PMRI /* \_SB_.PCI0.IDE1.PMRI */
                        GMUE = Local0
                        GMUT = PMUT /* \_SB_.PCI0.IDE1.PMUT */
                        GMCR = PMCR /* \_SB_.PCI0.IDE1.PMCR */
                        GSPT = PSRI /* \_SB_.PCI0.IDE1.PSRI */
                        GSUE = Local1
                        GSUT = PSUT /* \_SB_.PCI0.IDE1.PSUT */
                        GSCR = PSCR /* \_SB_.PCI0.IDE1.PSCR */
                        STM ()
                        PMRI = GMPT /* \_SB_.PCI0.IDE1.GMPT */
                        Local0 = GMUE /* \_SB_.PCI0.IDE1.GMUE */
                        PMUT = GMUT /* \_SB_.PCI0.IDE1.GMUT */
                        PMCR = GMCR /* \_SB_.PCI0.IDE1.GMCR */
                        Local1 = GSUE /* \_SB_.PCI0.IDE1.GSUE */
                        PSUT = GSUT /* \_SB_.PCI0.IDE1.GSUT */
                        PSCR = GSCR /* \_SB_.PCI0.IDE1.GSCR */
                        If ((Local0 & One))
                        {
                            PM3E = One
                        }
                        Else
                        {
                            PM3E = Zero
                        }

                        If ((Local0 & 0x02))
                        {
                            PM6E = One
                        }
                        Else
                        {
                            PM6E = Zero
                        }

                        If ((Local0 & 0x04))
                        {
                            PMAE = One
                        }
                        Else
                        {
                            PMAE = Zero
                        }

                        If ((Local1 & One))
                        {
                            PS3E = One
                        }
                        Else
                        {
                            PS3E = Zero
                        }

                        If ((Local1 & 0x02))
                        {
                            PS6E = One
                        }
                        Else
                        {
                            PS6E = Zero
                        }

                        If ((Local1 & 0x04))
                        {
                            PSAE = One
                        }
                        Else
                        {
                            PSAE = Zero
                        }

                        ATA0 = GTF (Zero, Arg1)
                        ATA1 = GTF (One, Arg2)
                    }

                    Device (DRV0)
                    {
                        Name (_ADR, Zero)  // _ADR: Address
                        Method (_GTF, 0, NotSerialized)  // _GTF: Get Task File
                        {
                            Return (RATA (ATA0))
                        }
                    }

                    Device (DRV1)
                    {
                        Name (_ADR, One)  // _ADR: Address
                        Method (_GTF, 0, NotSerialized)  // _GTF: Get Task File
                        {
                            Return (RATA (ATA1))
                        }
                    }
                }

                Device (CHN1)
                {
                    Name (_ADR, One)  // _ADR: Address
                    Method (_GTM, 0, NotSerialized)  // _GTM: Get Timing Mode
                    {
                        Local1 = (SSCR << One)
                        Local0 = (SMCR | Local1)
                        Local3 = (SMAE << 0x02)
                        Local4 = (SM6E << One)
                        Local3 |= Local4
                        Local1 = (SM3E | Local3)
                        Local3 = (SMPT << 0x04)
                        Local1 |= Local3
                        Local3 = (SSAE << 0x02)
                        Local4 = (SS6E << One)
                        Local3 |= Local4
                        Local2 = (SS3E | Local3)
                        Local3 = (SSPT << 0x04)
                        Local2 |= Local3
                        Return (GTM (SMRI, Local1, SMUT, SSRI, Local2, SSUT, Local0))
                    }

                    Method (_STM, 3, NotSerialized)  // _STM: Set Timing Mode
                    {
                        Debug = Arg0
                        TMD0 = Arg0
                        Local3 = (SMAE << 0x02)
                        Local4 = (SM6E << One)
                        Local3 |= Local4
                        Local0 = (SM3E | Local3)
                        Local3 = (SMPT << 0x04)
                        Local0 |= Local3
                        Local3 = (SSAE << 0x02)
                        Local4 = (SS6E << One)
                        Local3 |= Local4
                        Local1 = (SS3E | Local3)
                        Local3 = (SSPT << 0x04)
                        Local1 |= Local3
                        GMPT = SMRI /* \_SB_.PCI0.IDE1.SMRI */
                        GMUE = Local0
                        GMUT = SMUT /* \_SB_.PCI0.IDE1.SMUT */
                        GMCR = SMCR /* \_SB_.PCI0.IDE1.SMCR */
                        GSPT = SSRI /* \_SB_.PCI0.IDE1.SSRI */
                        GSUE = Local1
                        GSUT = SSUT /* \_SB_.PCI0.IDE1.SSUT */
                        GSCR = SSCR /* \_SB_.PCI0.IDE1.SSCR */
                        STM ()
                        SMRI = GMPT /* \_SB_.PCI0.IDE1.GMPT */
                        Local0 = GMUE /* \_SB_.PCI0.IDE1.GMUE */
                        SMUT = GMUT /* \_SB_.PCI0.IDE1.GMUT */
                        SMCR = GMCR /* \_SB_.PCI0.IDE1.GMCR */
                        Local1 = GSUE /* \_SB_.PCI0.IDE1.GSUE */
                        SSUT = GSUT /* \_SB_.PCI0.IDE1.GSUT */
                        SSCR = GSCR /* \_SB_.PCI0.IDE1.GSCR */
                        If ((Local0 & One))
                        {
                            SM3E = One
                        }
                        Else
                        {
                            SM3E = Zero
                        }

                        If ((Local0 & 0x02))
                        {
                            SM6E = One
                        }
                        Else
                        {
                            SM6E = Zero
                        }

                        If ((Local0 & 0x04))
                        {
                            SMAE = One
                        }
                        Else
                        {
                            SMAE = Zero
                        }

                        If ((Local1 & One))
                        {
                            SS3E = One
                        }
                        Else
                        {
                            SS3E = Zero
                        }

                        If ((Local1 & 0x02))
                        {
                            SS6E = One
                        }
                        Else
                        {
                            SS6E = Zero
                        }

                        If ((Local1 & 0x04))
                        {
                            SSAE = One
                        }
                        Else
                        {
                            SSAE = Zero
                        }

                        ATA2 = GTF (Zero, Arg1)
                        ATA3 = GTF (One, Arg2)
                    }

                    Device (DRV0)
                    {
                        Name (_ADR, Zero)  // _ADR: Address
                        Method (_GTF, 0, NotSerialized)  // _GTF: Get Task File
                        {
                            Return (RATA (ATA2))
                        }
                    }

                    Device (DRV1)
                    {
                        Name (_ADR, One)  // _ADR: Address
                        Method (_GTF, 0, NotSerialized)  // _GTF: Get Task File
                        {
                            Return (RATA (ATA3))
                        }
                    }
                }

                Method (GTM, 7, Serialized)
                {
                    PIO0 = Ones
                    PIO1 = Ones
                    DMA0 = Ones
                    DMA1 = Ones
                    CHNF = 0x10
                    If (REGF){}
                    Else
                    {
                        Return (TMD0) /* \_SB_.PCI0.IDE1.TMD0 */
                    }

                    If ((Arg1 & 0x20))
                    {
                        CHNF |= 0x02
                    }

                    Local6 = Match (DerefOf (TIM0 [One]), MEQ, Arg0, MTR, Zero, 
                        Zero)
                    Local7 = DerefOf (DerefOf (TIM0 [Zero]) [Local6])
                    DMA0 = Local7
                    PIO0 = Local7
                    If ((Arg4 & 0x20))
                    {
                        CHNF |= 0x08
                    }

                    Local6 = Match (DerefOf (TIM0 [0x02]), MEQ, Arg3, MTR, Zero, 
                        Zero)
                    Local7 = DerefOf (DerefOf (TIM0 [Zero]) [Local6])
                    DMA1 = Local7
                    PIO1 = Local7
                    If ((Arg1 & 0x07))
                    {
                        Local5 = Arg2
                        If ((Arg1 & 0x02))
                        {
                            Local5 += 0x02
                        }

                        If ((Arg1 & 0x04))
                        {
                            Local5 += 0x04
                        }

                        DMA0 = DerefOf (DerefOf (TIM0 [0x03]) [Local5])
                        CHNF |= One
                    }

                    If ((Arg4 & 0x07))
                    {
                        Local5 = Arg5
                        If ((Arg4 & 0x02))
                        {
                            Local5 += 0x02
                        }

                        If ((Arg4 & 0x04))
                        {
                            Local5 += 0x04
                        }

                        DMA1 = DerefOf (DerefOf (TIM0 [0x03]) [Local5])
                        CHNF |= 0x04
                    }

                    Debug = TMD0 /* \_SB_.PCI0.IDE1.TMD0 */
                    Return (TMD0) /* \_SB_.PCI0.IDE1.TMD0 */
                }

                Method (STM, 0, Serialized)
                {
                    If (REGF)
                    {
                        GMUE = Zero
                        GMUT = Zero
                        GSUE = Zero
                        GSUT = Zero
                        If ((CHNF & One))
                        {
                            Local0 = Match (DerefOf (TIM0 [0x03]), MLE, DMA0, MTR, Zero, 
                                Zero)
                            If ((Local0 > 0x05))
                            {
                                Local0 = 0x05
                            }

                            GMUT = DerefOf (DerefOf (TIM0 [0x04]) [Local0])
                            GMUE |= One
                            If ((Local0 > 0x02))
                            {
                                GMUE |= 0x02
                            }

                            If ((Local0 > 0x04))
                            {
                                GMUE &= 0xFD
                                GMUE |= 0x04
                            }
                        }
                        ElseIf (((PIO0 == Ones) | (PIO0 == Zero)))
                        {
                            If (((DMA0 < Ones) & (DMA0 > Zero)))
                            {
                                PIO0 = DMA0 /* \_SB_.PCI0.IDE1.DMA0 */
                                GMUE |= 0x80
                            }
                        }

                        If ((CHNF & 0x04))
                        {
                            Local0 = Match (DerefOf (TIM0 [0x03]), MLE, DMA1, MTR, Zero, 
                                Zero)
                            If ((Local0 > 0x05))
                            {
                                Local0 = 0x05
                            }

                            GSUT = DerefOf (DerefOf (TIM0 [0x04]) [Local0])
                            GSUE |= One
                            If ((Local0 > 0x02))
                            {
                                GSUE |= 0x02
                            }

                            If ((Local0 > 0x04))
                            {
                                GSUE &= 0xFD
                                GSUE |= 0x04
                            }
                        }
                        ElseIf (((PIO1 == Ones) | (PIO1 == Zero)))
                        {
                            If (((DMA1 < Ones) & (DMA1 > Zero)))
                            {
                                PIO1 = DMA1 /* \_SB_.PCI0.IDE1.DMA1 */
                                GSUE |= 0x80
                            }
                        }

                        If ((CHNF & 0x02))
                        {
                            GMUE |= 0x20
                        }

                        If ((CHNF & 0x08))
                        {
                            GSUE |= 0x20
                        }

                        Local0 = (Match (DerefOf (TIM0 [Zero]), MGE, PIO0, MTR, Zero, 
                            Zero) & 0x07)
                        Local1 = DerefOf (DerefOf (TIM0 [One]) [Local0])
                        GMPT = Local1
                        If ((Local0 < 0x03))
                        {
                            GMUE |= 0x50
                        }

                        Local0 = (Match (DerefOf (TIM0 [Zero]), MGE, PIO1, MTR, Zero, 
                            Zero) & 0x07)
                        Local1 = DerefOf (DerefOf (TIM0 [0x02]) [Local0])
                        GSPT = Local1
                        If ((Local0 < 0x03))
                        {
                            GSUE |= 0x50
                        }
                    }
                }

                Name (AT01, Buffer (0x07)
                {
                     0x03, 0x00, 0x00, 0x00, 0x00, 0x00, 0xEF         // .......
                })
                Name (AT02, Buffer (0x07)
                {
                     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x90         // .......
                })
                Name (AT03, Buffer (0x07)
                {
                     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xC6         // .......
                })
                Name (AT04, Buffer (0x07)
                {
                     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x91         // .......
                })
                Name (ATA0, Buffer (0x1D){})
                Name (ATA1, Buffer (0x1D){})
                Name (ATA2, Buffer (0x1D){})
                Name (ATA3, Buffer (0x1D){})
                Name (ATAB, Buffer (0x1D){})
                CreateByteField (ATAB, Zero, CMDC)
                Method (GTFB, 3, Serialized)
                {
                    Local0 = (CMDC * 0x38)
                    Local1 = (Local0 + 0x08)
                    CreateField (ATAB, Local1, 0x38, CMDX)
                    Local0 = (CMDC * 0x07)
                    CreateByteField (ATAB, (Local0 + 0x02), A001)
                    CreateByteField (ATAB, (Local0 + 0x06), A005)
                    CMDX = Arg0
                    A001 = Arg1
                    A005 = Arg2
                    CMDC++
                }

                Method (GTF, 2, Serialized)
                {
                    Debug = Arg1
                    CMDC = Zero
                    Name (ID49, 0x0C00)
                    Name (ID59, Zero)
                    Name (ID53, 0x04)
                    Name (ID63, 0x0F00)
                    Name (ID88, 0x0F00)
                    Name (IRDY, One)
                    Name (PIOT, Zero)
                    Name (DMAT, Zero)
                    If ((SizeOf (Arg1) == 0x0200))
                    {
                        CreateWordField (Arg1, 0x62, IW49)
                        ID49 = IW49 /* \_SB_.PCI0.IDE1.GTF_.IW49 */
                        CreateWordField (Arg1, 0x6A, IW53)
                        ID53 = IW53 /* \_SB_.PCI0.IDE1.GTF_.IW53 */
                        CreateWordField (Arg1, 0x7E, IW63)
                        ID63 = IW63 /* \_SB_.PCI0.IDE1.GTF_.IW63 */
                        CreateWordField (Arg1, 0x76, IW59)
                        ID59 = IW59 /* \_SB_.PCI0.IDE1.GTF_.IW59 */
                        CreateWordField (Arg1, 0xB0, IW88)
                        ID88 = IW88 /* \_SB_.PCI0.IDE1.GTF_.IW88 */
                    }

                    Local7 = 0xA0
                    If (Arg0)
                    {
                        Local7 = 0xB0
                        IRDY = (CHNF & 0x08)
                        If ((CHNF & 0x10))
                        {
                            PIOT = PIO1 /* \_SB_.PCI0.IDE1.PIO1 */
                        }
                        Else
                        {
                            PIOT = PIO0 /* \_SB_.PCI0.IDE1.PIO0 */
                        }

                        If ((CHNF & 0x04))
                        {
                            If ((CHNF & 0x10))
                            {
                                DMAT = DMA1 /* \_SB_.PCI0.IDE1.DMA1 */
                            }
                            Else
                            {
                                DMAT = DMA0 /* \_SB_.PCI0.IDE1.DMA0 */
                            }
                        }
                    }
                    Else
                    {
                        IRDY = (CHNF & 0x02)
                        PIOT = PIO0 /* \_SB_.PCI0.IDE1.PIO0 */
                        If ((CHNF & One))
                        {
                            DMAT = DMA0 /* \_SB_.PCI0.IDE1.DMA0 */
                        }
                    }

                    If ((((ID53 & 0x04) && (ID88 & 0xFF00)) && DMAT))
                    {
                        Local1 = Match (DerefOf (TIM0 [0x03]), MLE, DMAT, MTR, Zero, 
                            Zero)
                        If ((Local1 > 0x05))
                        {
                            Local1 = 0x05
                        }

                        GTFB (AT01, (0x40 | Local1), Local7)
                    }
                    ElseIf (((ID63 & 0xFF00) && PIOT))
                    {
                        Local0 = (Match (DerefOf (TIM0 [Zero]), MGE, PIOT, MTR, Zero, 
                            Zero) & 0x03)
                        Local1 = (0x20 | DerefOf (DerefOf (TIM0 [0x07]) [Local0]))
                        GTFB (AT01, Local1, Local7)
                    }

                    If (IRDY)
                    {
                        Local0 = (Match (DerefOf (TIM0 [Zero]), MGE, PIOT, MTR, Zero, 
                            Zero) & 0x07)
                        Local1 = (0x08 | DerefOf (DerefOf (TIM0 [0x06]) [Local0]))
                        GTFB (AT01, Local1, Local7)
                    }
                    ElseIf ((ID49 & 0x0400))
                    {
                        GTFB (AT01, One, Local7)
                    }

                    If (((ID59 & 0x0100) && (ID59 & 0xFF)))
                    {
                        GTFB (AT03, (ID59 & 0xFF), Local7)
                    }

                    Debug = ATAB /* \_SB_.PCI0.IDE1.ATAB */
                    Return (ATAB) /* \_SB_.PCI0.IDE1.ATAB */
                }

                Method (RATA, 1, NotSerialized)
                {
                    CreateByteField (Arg0, Zero, CMDN)
                    Local0 = (CMDN * 0x38)
                    CreateField (Arg0, 0x08, Local0, RETB)
                    Debug = RETB /* \_SB_.PCI0.IDE1.RATA.RETB */
                    Return (Concatenate (RETB, FZTF))
                }
            }

            Device (P0P4)
            {
                Name (_ADR, 0x001C0000)  // _ADR: Address
                Method (_PRW, 0, NotSerialized)  // _PRW: Power Resources for Wake
                {
                    Return (GPRW (0x09, 0x04))
                }

                Method (_PRT, 0, NotSerialized)  // _PRT: PCI Routing Table
                {
                    If (PICM)
                    {
                        Return (AR04) /* \_SB_.AR04 */
                    }

                    Return (PR04) /* \_SB_.PR04 */
                }

                Device (GBE)
                {
                    Name (_ADR, 0xFFFF)  // _ADR: Address
                    Method (_PRW, 0, NotSerialized)  // _PRW: Power Resources for Wake
                    {
                        Return (GPRW (0x0D, 0x04))
                    }
                }
            }

            Device (P0P5)
            {
                Name (_ADR, 0x001C0001)  // _ADR: Address
                Method (_PRW, 0, NotSerialized)  // _PRW: Power Resources for Wake
                {
                    Return (GPRW (0x09, 0x04))
                }

                Method (_PRT, 0, NotSerialized)  // _PRT: PCI Routing Table
                {
                    If (PICM)
                    {
                        Return (AR05) /* \_SB_.AR05 */
                    }

                    Return (PR05) /* \_SB_.PR05 */
                }
            }

            Device (P0P6)
            {
                Name (_ADR, 0x001C0002)  // _ADR: Address
                Method (_PRW, 0, NotSerialized)  // _PRW: Power Resources for Wake
                {
                    Return (GPRW (0x09, 0x04))
                }

                Method (_PRT, 0, NotSerialized)  // _PRT: PCI Routing Table
                {
                    If (PICM)
                    {
                        Return (AR06) /* \_SB_.AR06 */
                    }

                    Return (PR06) /* \_SB_.PR06 */
                }
            }

            Device (P0P7)
            {
                Name (_ADR, 0x001C0003)  // _ADR: Address
                Method (_PRW, 0, NotSerialized)  // _PRW: Power Resources for Wake
                {
                    Return (GPRW (0x09, 0x04))
                }

                Method (_PRT, 0, NotSerialized)  // _PRT: PCI Routing Table
                {
                    If (PICM)
                    {
                        Return (AR07) /* \_SB_.AR07 */
                    }

                    Return (PR07) /* \_SB_.PR07 */
                }
            }

            Device (P0P8)
            {
                Name (_ADR, 0x001C0004)  // _ADR: Address
                Method (_PRW, 0, NotSerialized)  // _PRW: Power Resources for Wake
                {
                    Return (GPRW (0x09, 0x04))
                }

                Method (_PRT, 0, NotSerialized)  // _PRT: PCI Routing Table
                {
                    If (PICM)
                    {
                        Return (AR08) /* \_SB_.AR08 */
                    }

                    Return (PR08) /* \_SB_.PR08 */
                }
            }

            Device (P0P9)
            {
                Name (_ADR, 0x001C0005)  // _ADR: Address
                Method (_PRW, 0, NotSerialized)  // _PRW: Power Resources for Wake
                {
                    Return (GPRW (0x09, 0x04))
                }

                Method (_PRT, 0, NotSerialized)  // _PRT: PCI Routing Table
                {
                    If (PICM)
                    {
                        Return (AR09) /* \_SB_.AR09 */
                    }

                    Return (PR09) /* \_SB_.PR09 */
                }
            }

            Device (VGA)
            {
                Name (_ADR, 0x00020000)  // _ADR: Address
                OperationRegion (VSID, PCI_Config, Zero, 0x04)
                Field (VSID, ByteAcc, NoLock, Preserve)
                {
                    REG0,   32
                }

                Method (PRST, 0, NotSerialized)
                {
                    If ((REG0 == Ones))
                    {
                        Return (Zero)
                    }
                    Else
                    {
                        Return (One)
                    }
                }

                Name (LCDM, 0x0808)
                Name (CRTM, 0x0101)
                Name (TVOM, 0x0202)
                Name (DONE, Zero)
                Name (DOSF, One)
                Name (UPDN, One)
                Name (NXTD, One)
                Method (MD2A, 1, NotSerialized)
                {
                    Local0 = Zero
                    If ((Arg0 & LCDM))
                    {
                        Local0 |= One
                    }

                    If ((Arg0 & CRTM))
                    {
                        Local0 |= 0x02
                    }

                    If ((Arg0 & TVOM))
                    {
                        Local0 |= 0x04
                    }

                    If (!Local0)
                    {
                        Return (NXTD) /* \_SB_.PCI0.VGA_.NXTD */
                    }

                    Return (Local0)
                }

                Method (MA2D, 1, NotSerialized)
                {
                    Local0 = Zero
                    If ((Arg0 & One))
                    {
                        Local0 |= LCDM /* \_SB_.PCI0.VGA_.LCDM */
                    }

                    If ((Arg0 & 0x02))
                    {
                        Local0 |= CRTM /* \_SB_.PCI0.VGA_.CRTM */
                    }

                    If ((Arg0 & 0x04))
                    {
                        Local0 |= TVOM /* \_SB_.PCI0.VGA_.TVOM */
                    }

                    If (!Local0)
                    {
                        Return (LCDM) /* \_SB_.PCI0.VGA_.LCDM */
                    }

                    Return (Local0)
                }

                Method (_INI, 0, NotSerialized)  // _INI: Initialize
                {
                    GCAD ()
                    PADL = CADL /* \CADL */
                    GCDD ()
                    GNDD ()
                }

                Method (_DOS, 1, NotSerialized)  // _DOS: Disable Output Switching
                {
                    DOSF = Arg0
                }

                Method (_DOD, 0, NotSerialized)  // _DOD: Display Output Devices
                {
                    Return (Package (0x02)
                    {
                        0x00010100, 
                        0x00010400
                    })
                }

                Device (CRTD)
                {
                    Name (_ADR, 0x0100)  // _ADR: Address
                    Method (_DCS, 0, NotSerialized)  // _DCS: Display Current Status
                    {
                        If ((CSTE & CRTM))
                        {
                            Return (0x1F)
                        }

                        Return (0x1D)
                    }

                    Method (_DGS, 0, NotSerialized)  // _DGS: Display Graphics State
                    {
                        If ((NSTE & CRTM))
                        {
                            Return (One)
                        }

                        Return (Zero)
                    }

                    Method (_DSS, 1, NotSerialized)  // _DSS: Device Set State
                    {
                        If ((Arg0 & 0x40000000))
                        {
                            If ((Arg0 & 0x80000000))
                            {
                                CSTE = NSTE /* \NSTE */
                                DONE = One
                            }
                        }
                    }
                }

                Device (LCDD)
                {
                    Name (_ADR, 0x04070400)  // _ADR: Address
                    Method (_DCS, 0, NotSerialized)  // _DCS: Display Current Status
                    {
                        If ((CSTE & LCDM))
                        {
                            Return (0x1F)
                        }

                        Return (0x1D)
                    }

                    Method (_DGS, 0, NotSerialized)  // _DGS: Display Graphics State
                    {
                        If ((NSTE & LCDM))
                        {
                            Return (One)
                        }

                        Return (Zero)
                    }

                    Method (_DSS, 1, NotSerialized)  // _DSS: Device Set State
                    {
                        If ((Arg0 & 0x40000000))
                        {
                            If ((Arg0 & 0x80000000))
                            {
                                CSTE = NSTE /* \NSTE */
                                DONE = One
                            }
                        }
                    }

                    Method (_BCL, 0, NotSerialized)  // _BCL: Brightness Control Levels
                    {
                        Return (Package (0x12)
                        {
                            0x0F, 
                            0x08, 
                            0x0F, 
                            0x0E, 
                            0x0D, 
                            0x0C, 
                            0x0B, 
                            0x0A, 
                            0x09, 
                            0x08, 
                            0x07, 
                            0x06, 
                            0x05, 
                            0x04, 
                            0x03, 
                            0x02, 
                            One, 
                            Zero
                        })
                    }

                    Method (_BCM, 1, NotSerialized)  // _BCM: Brightness Control Method
                    {
                        LBTN = Arg0
                        ^^^SBRG.EC0.STBR ()
                    }

                    Method (_BQC, 0, NotSerialized)  // _BQC: Brightness Query Current
                    {
                        Return (LBTN) /* \LBTN */
                    }
                }

                Method (SWHD, 1, Serialized)
                {
                    UPDN = One
                    If (DOSF)
                    {
                        If (\NATK ())
                        {
                            SFUN = Zero
                        }
                        Else
                        {
                            SFUN = 0x04
                        }

                        SSTE = Arg0
                        If (\NATK ())
                        {
                            NSTE = MA2D (Arg0)
                            SSTE = NSTE /* \NSTE */
                        }

                        ISMI (0x94)
                        Notify (VGA, 0x81) // Information Change
                    }
                    Else
                    {
                        If ((CADL != PADL))
                        {
                            PADL = CADL /* \CADL */
                            Notify (PCI0, Zero) // Bus Check
                            Sleep (0x03E8)
                        }

                        DONE = Zero
                        Notify (VGA, 0x80) // Status Change
                        Local0 = 0x01F4
                        While (Local0)
                        {
                            If (DONE)
                            {
                                Local0 = Zero
                            }
                            Else
                            {
                                Sleep (0x0A)
                                Local0--
                            }
                        }
                    }
                }

                Method (GCDD, 0, NotSerialized)
                {
                    SFUN = One
                    ISMI (0x95)
                    Return (CSTE) /* \CSTE */
                }

                Method (GNDD, 0, NotSerialized)
                {
                    SFUN = 0x05
                    ISMI (0x95)
                    Return (NSTE) /* \NSTE */
                }

                Method (GCAD, 0, NotSerialized)
                {
                    SFUN = 0x02
                    ISMI (0x95)
                    Return (CADL) /* \CADL */
                }

                Method (ADVD, 0, NotSerialized)
                {
                    GCDD ()
                    GCAD ()
                    If (\NATK ())
                    {
                        If (UPDN)
                        {
                            NXTD = MD2A (CSTE)
                            UPDN = Zero
                        }

                        Local0 = Zero
                        Local1 = MD2A (CADL)
                        While ((NXTD != Local0))
                        {
                            NXTD++
                            If ((NXTD > 0x03))
                            {
                                NXTD = One
                            }

                            Local0 = (NXTD & Local1)
                        }

                        NSTE = MA2D (NXTD)
                        DBG8 = NXTD /* \_SB_.PCI0.VGA_.NXTD */
                        Return (NXTD) /* \_SB_.PCI0.VGA_.NXTD */
                    }

                    Return (GNDD ())
                }

                Method (NATK, 0, NotSerialized)
                {
                    Return (One)
                }
            }

            Device (USB0)
            {
                Name (_ADR, 0x001D0000)  // _ADR: Address
                Method (_S3D, 0, NotSerialized)  // _S3D: S3 Device State
                {
                    If (((OSFL () == One) || (OSFL () == 0x02)))
                    {
                        Return (0x02)
                    }
                    Else
                    {
                        Return (0x03)
                    }
                }

                Device (RHUB)
                {
                    Name (_ADR, Zero)  // _ADR: Address
                    Device (PRT1)
                    {
                        Name (_ADR, One)  // _ADR: Address
                        Name (_UPC, Package (0x04)  // _UPC: USB Port Capabilities
                        {
                            0xFF, 
                            Zero, 
                            Zero, 
                            Zero
                        })
                        Name (_PLD, ToPLD (
                            PLD_Revision           = 0x1,
                            PLD_IgnoreColor        = 0x1,
                            PLD_Red                = 0x0,
                            PLD_Green              = 0x0,
                            PLD_Blue               = 0x0,
                            PLD_Width              = 0x0,
                            PLD_Height             = 0x0,
                            PLD_UserVisible        = 0x1,
                            PLD_Dock               = 0x0,
                            PLD_Lid                = 0x0,
                            PLD_Panel              = "FRONT",
                            PLD_VerticalPosition   = "LOWER",
                            PLD_HorizontalPosition = "LEFT",
                            PLD_Shape              = "HORIZONTALRECTANGLE",
                            PLD_GroupOrientation   = 0x0,
                            PLD_GroupToken         = 0x0,
                            PLD_GroupPosition      = 0x0,
                            PLD_Bay                = 0x0,
                            PLD_Ejectable          = 0x1,
                            PLD_EjectRequired      = 0x1,
                            PLD_CabinetNumber      = 0x0,
                            PLD_CardCageNumber     = 0x0,
                            PLD_Reference          = 0x0,
                            PLD_Rotation           = 0x0,
                            PLD_Order              = 0x0)
)  // _PLD: Physical Location of Device
                    }

                    Device (PRT2)
                    {
                        Name (_ADR, 0x02)  // _ADR: Address
                        Name (_UPC, Package (0x04)  // _UPC: USB Port Capabilities
                        {
                            0xFF, 
                            Zero, 
                            Zero, 
                            Zero
                        })
                        Name (_PLD, ToPLD (
                            PLD_Revision           = 0x1,
                            PLD_IgnoreColor        = 0x1,
                            PLD_Red                = 0x0,
                            PLD_Green              = 0x0,
                            PLD_Blue               = 0x0,
                            PLD_Width              = 0x0,
                            PLD_Height             = 0x0,
                            PLD_UserVisible        = 0x1,
                            PLD_Dock               = 0x0,
                            PLD_Lid                = 0x0,
                            PLD_Panel              = "FRONT",
                            PLD_VerticalPosition   = "LOWER",
                            PLD_HorizontalPosition = "LEFT",
                            PLD_Shape              = "HORIZONTALRECTANGLE",
                            PLD_GroupOrientation   = 0x0,
                            PLD_GroupToken         = 0x0,
                            PLD_GroupPosition      = 0x0,
                            PLD_Bay                = 0x0,
                            PLD_Ejectable          = 0x1,
                            PLD_EjectRequired      = 0x1,
                            PLD_CabinetNumber      = 0x0,
                            PLD_CardCageNumber     = 0x0,
                            PLD_Reference          = 0x0,
                            PLD_Rotation           = 0x0,
                            PLD_Order              = 0x0)
)  // _PLD: Physical Location of Device
                    }
                }

                Method (_PRW, 0, NotSerialized)  // _PRW: Power Resources for Wake
                {
                    Return (GPRW (0x03, 0x03))
                }
            }

            Device (USB1)
            {
                Name (_ADR, 0x001D0001)  // _ADR: Address
                Method (_S3D, 0, NotSerialized)  // _S3D: S3 Device State
                {
                    If (((OSFL () == One) || (OSFL () == 0x02)))
                    {
                        Return (0x02)
                    }
                    Else
                    {
                        Return (0x03)
                    }
                }

                Device (RHUB)
                {
                    Name (_ADR, Zero)  // _ADR: Address
                    Device (PRT1)
                    {
                        Name (_ADR, One)  // _ADR: Address
                        Name (_UPC, Package (0x04)  // _UPC: USB Port Capabilities
                        {
                            0xFF, 
                            Zero, 
                            Zero, 
                            Zero
                        })
                        Name (_PLD, ToPLD (
                            PLD_Revision           = 0x1,
                            PLD_IgnoreColor        = 0x1,
                            PLD_Red                = 0x0,
                            PLD_Green              = 0x0,
                            PLD_Blue               = 0x0,
                            PLD_Width              = 0x0,
                            PLD_Height             = 0x0,
                            PLD_UserVisible        = 0x1,
                            PLD_Dock               = 0x0,
                            PLD_Lid                = 0x0,
                            PLD_Panel              = "FRONT",
                            PLD_VerticalPosition   = "LOWER",
                            PLD_HorizontalPosition = "LEFT",
                            PLD_Shape              = "HORIZONTALRECTANGLE",
                            PLD_GroupOrientation   = 0x0,
                            PLD_GroupToken         = 0x0,
                            PLD_GroupPosition      = 0x0,
                            PLD_Bay                = 0x0,
                            PLD_Ejectable          = 0x1,
                            PLD_EjectRequired      = 0x1,
                            PLD_CabinetNumber      = 0x0,
                            PLD_CardCageNumber     = 0x0,
                            PLD_Reference          = 0x0,
                            PLD_Rotation           = 0x0,
                            PLD_Order              = 0x0)
)  // _PLD: Physical Location of Device
                    }

                    Device (PRT2)
                    {
                        Name (_ADR, 0x02)  // _ADR: Address
                        Name (_UPC, Package (0x04)  // _UPC: USB Port Capabilities
                        {
                            0xFF, 
                            Zero, 
                            Zero, 
                            Zero
                        })
                        Name (_PLD, ToPLD (
                            PLD_Revision           = 0x1,
                            PLD_IgnoreColor        = 0x1,
                            PLD_Red                = 0x0,
                            PLD_Green              = 0x0,
                            PLD_Blue               = 0x0,
                            PLD_Width              = 0x0,
                            PLD_Height             = 0x0,
                            PLD_UserVisible        = 0x1,
                            PLD_Dock               = 0x0,
                            PLD_Lid                = 0x0,
                            PLD_Panel              = "FRONT",
                            PLD_VerticalPosition   = "LOWER",
                            PLD_HorizontalPosition = "LEFT",
                            PLD_Shape              = "HORIZONTALRECTANGLE",
                            PLD_GroupOrientation   = 0x0,
                            PLD_GroupToken         = 0x0,
                            PLD_GroupPosition      = 0x0,
                            PLD_Bay                = 0x0,
                            PLD_Ejectable          = 0x1,
                            PLD_EjectRequired      = 0x1,
                            PLD_CabinetNumber      = 0x0,
                            PLD_CardCageNumber     = 0x0,
                            PLD_Reference          = 0x0,
                            PLD_Rotation           = 0x0,
                            PLD_Order              = 0x0)
)  // _PLD: Physical Location of Device
                    }
                }

                Method (_PRW, 0, NotSerialized)  // _PRW: Power Resources for Wake
                {
                    Return (GPRW (0x04, 0x03))
                }
            }

            Device (USB2)
            {
                Name (_ADR, 0x001D0002)  // _ADR: Address
                Method (_S3D, 0, NotSerialized)  // _S3D: S3 Device State
                {
                    If (((OSFL () == One) || (OSFL () == 0x02)))
                    {
                        Return (0x02)
                    }
                    Else
                    {
                        Return (0x03)
                    }
                }

                Device (RHUB)
                {
                    Name (_ADR, Zero)  // _ADR: Address
                    Device (PRT1)
                    {
                        Name (_ADR, One)  // _ADR: Address
                        Name (_UPC, Package (0x04)  // _UPC: USB Port Capabilities
                        {
                            0xFF, 
                            Zero, 
                            Zero, 
                            Zero
                        })
                        Name (_PLD, ToPLD (
                            PLD_Revision           = 0x1,
                            PLD_IgnoreColor        = 0x1,
                            PLD_Red                = 0x0,
                            PLD_Green              = 0x0,
                            PLD_Blue               = 0x0,
                            PLD_Width              = 0x0,
                            PLD_Height             = 0x0,
                            PLD_UserVisible        = 0x1,
                            PLD_Dock               = 0x0,
                            PLD_Lid                = 0x0,
                            PLD_Panel              = "FRONT",
                            PLD_VerticalPosition   = "LOWER",
                            PLD_HorizontalPosition = "LEFT",
                            PLD_Shape              = "HORIZONTALRECTANGLE",
                            PLD_GroupOrientation   = 0x0,
                            PLD_GroupToken         = 0x0,
                            PLD_GroupPosition      = 0x0,
                            PLD_Bay                = 0x0,
                            PLD_Ejectable          = 0x1,
                            PLD_EjectRequired      = 0x1,
                            PLD_CabinetNumber      = 0x0,
                            PLD_CardCageNumber     = 0x0,
                            PLD_Reference          = 0x0,
                            PLD_Rotation           = 0x0,
                            PLD_Order              = 0x0)
)  // _PLD: Physical Location of Device
                    }

                    Device (PRT2)
                    {
                        Name (_ADR, 0x02)  // _ADR: Address
                        Name (_UPC, Package (0x04)  // _UPC: USB Port Capabilities
                        {
                            0xFF, 
                            Zero, 
                            Zero, 
                            Zero
                        })
                        Name (_PLD, ToPLD (
                            PLD_Revision           = 0x1,
                            PLD_IgnoreColor        = 0x1,
                            PLD_Red                = 0x0,
                            PLD_Green              = 0x0,
                            PLD_Blue               = 0x0,
                            PLD_Width              = 0x0,
                            PLD_Height             = 0x0,
                            PLD_UserVisible        = 0x0,
                            PLD_Dock               = 0x0,
                            PLD_Lid                = 0x0,
                            PLD_Panel              = "FRONT",
                            PLD_VerticalPosition   = "LOWER",
                            PLD_HorizontalPosition = "LEFT",
                            PLD_Shape              = "HORIZONTALRECTANGLE",
                            PLD_GroupOrientation   = 0x0,
                            PLD_GroupToken         = 0x0,
                            PLD_GroupPosition      = 0x0,
                            PLD_Bay                = 0x0,
                            PLD_Ejectable          = 0x1,
                            PLD_EjectRequired      = 0x1,
                            PLD_CabinetNumber      = 0x0,
                            PLD_CardCageNumber     = 0x0,
                            PLD_Reference          = 0x0,
                            PLD_Rotation           = 0x0,
                            PLD_Order              = 0x0)
)  // _PLD: Physical Location of Device
                    }
                }

                Method (_PRW, 0, NotSerialized)  // _PRW: Power Resources for Wake
                {
                    Return (GPRW (0x0C, 0x03))
                }
            }

            Device (USB3)
            {
                Name (_ADR, 0x001D0003)  // _ADR: Address
                Method (_S3D, 0, NotSerialized)  // _S3D: S3 Device State
                {
                    If (((OSFL () == One) || (OSFL () == 0x02)))
                    {
                        Return (0x02)
                    }
                    Else
                    {
                        Return (0x03)
                    }
                }

                Device (RHUB)
                {
                    Name (_ADR, Zero)  // _ADR: Address
                    Device (PRT1)
                    {
                        Name (_ADR, One)  // _ADR: Address
                        Name (_UPC, Package (0x04)  // _UPC: USB Port Capabilities
                        {
                            0xFF, 
                            Zero, 
                            Zero, 
                            Zero
                        })
                        Name (_PLD, ToPLD (
                            PLD_Revision           = 0x1,
                            PLD_IgnoreColor        = 0x1,
                            PLD_Red                = 0x0,
                            PLD_Green              = 0x0,
                            PLD_Blue               = 0x0,
                            PLD_Width              = 0x0,
                            PLD_Height             = 0x0,
                            PLD_UserVisible        = 0x1,
                            PLD_Dock               = 0x0,
                            PLD_Lid                = 0x0,
                            PLD_Panel              = "FRONT",
                            PLD_VerticalPosition   = "LOWER",
                            PLD_HorizontalPosition = "LEFT",
                            PLD_Shape              = "HORIZONTALRECTANGLE",
                            PLD_GroupOrientation   = 0x0,
                            PLD_GroupToken         = 0x0,
                            PLD_GroupPosition      = 0x0,
                            PLD_Bay                = 0x0,
                            PLD_Ejectable          = 0x1,
                            PLD_EjectRequired      = 0x1,
                            PLD_CabinetNumber      = 0x0,
                            PLD_CardCageNumber     = 0x0,
                            PLD_Reference          = 0x0,
                            PLD_Rotation           = 0x0,
                            PLD_Order              = 0x0)
)  // _PLD: Physical Location of Device
                    }

                    Device (PRT2)
                    {
                        Name (_ADR, 0x02)  // _ADR: Address
                        Name (_UPC, Package (0x04)  // _UPC: USB Port Capabilities
                        {
                            0xFF, 
                            Zero, 
                            Zero, 
                            Zero
                        })
                        Name (_PLD, ToPLD (
                            PLD_Revision           = 0x1,
                            PLD_IgnoreColor        = 0x1,
                            PLD_Red                = 0x0,
                            PLD_Green              = 0x0,
                            PLD_Blue               = 0x0,
                            PLD_Width              = 0x0,
                            PLD_Height             = 0x0,
                            PLD_UserVisible        = 0x0,
                            PLD_Dock               = 0x0,
                            PLD_Lid                = 0x0,
                            PLD_Panel              = "FRONT",
                            PLD_VerticalPosition   = "LOWER",
                            PLD_HorizontalPosition = "LEFT",
                            PLD_Shape              = "HORIZONTALRECTANGLE",
                            PLD_GroupOrientation   = 0x0,
                            PLD_GroupToken         = 0x0,
                            PLD_GroupPosition      = 0x0,
                            PLD_Bay                = 0x0,
                            PLD_Ejectable          = 0x1,
                            PLD_EjectRequired      = 0x1,
                            PLD_CabinetNumber      = 0x0,
                            PLD_CardCageNumber     = 0x0,
                            PLD_Reference          = 0x0,
                            PLD_Rotation           = 0x0,
                            PLD_Order              = 0x0)
)  // _PLD: Physical Location of Device
                    }
                }

                Method (_PRW, 0, NotSerialized)  // _PRW: Power Resources for Wake
                {
                    Return (GPRW (0x0E, 0x03))
                }
            }

            Device (EUSB)
            {
                Name (_ADR, 0x001D0007)  // _ADR: Address
                Method (_S3D, 0, NotSerialized)  // _S3D: S3 Device State
                {
                    If (((OSFL () == One) || (OSFL () == 0x02)))
                    {
                        Return (0x02)
                    }
                    Else
                    {
                        Return (0x03)
                    }
                }

                Device (RHUB)
                {
                    Name (_ADR, Zero)  // _ADR: Address
                    Device (PRT1)
                    {
                        Name (_ADR, One)  // _ADR: Address
                        Name (_UPC, Package (0x04)  // _UPC: USB Port Capabilities
                        {
                            0xFF, 
                            Zero, 
                            Zero, 
                            Zero
                        })
                        Name (_PLD, ToPLD (
                            PLD_Revision           = 0x1,
                            PLD_IgnoreColor        = 0x1,
                            PLD_Red                = 0x0,
                            PLD_Green              = 0x0,
                            PLD_Blue               = 0x0,
                            PLD_Width              = 0x0,
                            PLD_Height             = 0x0,
                            PLD_UserVisible        = 0x1,
                            PLD_Dock               = 0x0,
                            PLD_Lid                = 0x0,
                            PLD_Panel              = "FRONT",
                            PLD_VerticalPosition   = "LOWER",
                            PLD_HorizontalPosition = "LEFT",
                            PLD_Shape              = "HORIZONTALRECTANGLE",
                            PLD_GroupOrientation   = 0x0,
                            PLD_GroupToken         = 0x0,
                            PLD_GroupPosition      = 0x0,
                            PLD_Bay                = 0x0,
                            PLD_Ejectable          = 0x1,
                            PLD_EjectRequired      = 0x1,
                            PLD_CabinetNumber      = 0x0,
                            PLD_CardCageNumber     = 0x0,
                            PLD_Reference          = 0x0,
                            PLD_Rotation           = 0x0,
                            PLD_Order              = 0x0)
)  // _PLD: Physical Location of Device
                    }

                    Device (PRT2)
                    {
                        Name (_ADR, 0x02)  // _ADR: Address
                        Name (_UPC, Package (0x04)  // _UPC: USB Port Capabilities
                        {
                            0xFF, 
                            Zero, 
                            Zero, 
                            Zero
                        })
                        Name (_PLD, ToPLD (
                            PLD_Revision           = 0x1,
                            PLD_IgnoreColor        = 0x1,
                            PLD_Red                = 0x0,
                            PLD_Green              = 0x0,
                            PLD_Blue               = 0x0,
                            PLD_Width              = 0x0,
                            PLD_Height             = 0x0,
                            PLD_UserVisible        = 0x1,
                            PLD_Dock               = 0x0,
                            PLD_Lid                = 0x0,
                            PLD_Panel              = "FRONT",
                            PLD_VerticalPosition   = "LOWER",
                            PLD_HorizontalPosition = "LEFT",
                            PLD_Shape              = "HORIZONTALRECTANGLE",
                            PLD_GroupOrientation   = 0x0,
                            PLD_GroupToken         = 0x0,
                            PLD_GroupPosition      = 0x0,
                            PLD_Bay                = 0x0,
                            PLD_Ejectable          = 0x1,
                            PLD_EjectRequired      = 0x1,
                            PLD_CabinetNumber      = 0x0,
                            PLD_CardCageNumber     = 0x0,
                            PLD_Reference          = 0x0,
                            PLD_Rotation           = 0x0,
                            PLD_Order              = 0x0)
)  // _PLD: Physical Location of Device
                    }

                    Device (PRT3)
                    {
                        Name (_ADR, 0x03)  // _ADR: Address
                        Name (_UPC, Package (0x04)  // _UPC: USB Port Capabilities
                        {
                            0xFF, 
                            Zero, 
                            Zero, 
                            Zero
                        })
                        Name (_PLD, ToPLD (
                            PLD_Revision           = 0x1,
                            PLD_IgnoreColor        = 0x1,
                            PLD_Red                = 0x0,
                            PLD_Green              = 0x0,
                            PLD_Blue               = 0x0,
                            PLD_Width              = 0x0,
                            PLD_Height             = 0x0,
                            PLD_UserVisible        = 0x1,
                            PLD_Dock               = 0x0,
                            PLD_Lid                = 0x0,
                            PLD_Panel              = "FRONT",
                            PLD_VerticalPosition   = "LOWER",
                            PLD_HorizontalPosition = "LEFT",
                            PLD_Shape              = "HORIZONTALRECTANGLE",
                            PLD_GroupOrientation   = 0x0,
                            PLD_GroupToken         = 0x0,
                            PLD_GroupPosition      = 0x0,
                            PLD_Bay                = 0x0,
                            PLD_Ejectable          = 0x1,
                            PLD_EjectRequired      = 0x1,
                            PLD_CabinetNumber      = 0x0,
                            PLD_CardCageNumber     = 0x0,
                            PLD_Reference          = 0x0,
                            PLD_Rotation           = 0x0,
                            PLD_Order              = 0x0)
)  // _PLD: Physical Location of Device
                    }

                    Device (PRT4)
                    {
                        Name (_ADR, 0x04)  // _ADR: Address
                        Name (_UPC, Package (0x04)  // _UPC: USB Port Capabilities
                        {
                            0xFF, 
                            Zero, 
                            Zero, 
                            Zero
                        })
                        Name (_PLD, ToPLD (
                            PLD_Revision           = 0x1,
                            PLD_IgnoreColor        = 0x1,
                            PLD_Red                = 0x0,
                            PLD_Green              = 0x0,
                            PLD_Blue               = 0x0,
                            PLD_Width              = 0x0,
                            PLD_Height             = 0x0,
                            PLD_UserVisible        = 0x1,
                            PLD_Dock               = 0x0,
                            PLD_Lid                = 0x0,
                            PLD_Panel              = "FRONT",
                            PLD_VerticalPosition   = "LOWER",
                            PLD_HorizontalPosition = "LEFT",
                            PLD_Shape              = "HORIZONTALRECTANGLE",
                            PLD_GroupOrientation   = 0x0,
                            PLD_GroupToken         = 0x0,
                            PLD_GroupPosition      = 0x0,
                            PLD_Bay                = 0x0,
                            PLD_Ejectable          = 0x1,
                            PLD_EjectRequired      = 0x1,
                            PLD_CabinetNumber      = 0x0,
                            PLD_CardCageNumber     = 0x0,
                            PLD_Reference          = 0x0,
                            PLD_Rotation           = 0x0,
                            PLD_Order              = 0x0)
)  // _PLD: Physical Location of Device
                    }

                    Device (PRT5)
                    {
                        Name (_ADR, 0x05)  // _ADR: Address
                        Name (_UPC, Package (0x04)  // _UPC: USB Port Capabilities
                        {
                            0xFF, 
                            Zero, 
                            Zero, 
                            Zero
                        })
                        Name (_PLD, ToPLD (
                            PLD_Revision           = 0x1,
                            PLD_IgnoreColor        = 0x1,
                            PLD_Red                = 0x0,
                            PLD_Green              = 0x0,
                            PLD_Blue               = 0x0,
                            PLD_Width              = 0x0,
                            PLD_Height             = 0x0,
                            PLD_UserVisible        = 0x0,
                            PLD_Dock               = 0x0,
                            PLD_Lid                = 0x0,
                            PLD_Panel              = "FRONT",
                            PLD_VerticalPosition   = "LOWER",
                            PLD_HorizontalPosition = "LEFT",
                            PLD_Shape              = "HORIZONTALRECTANGLE",
                            PLD_GroupOrientation   = 0x0,
                            PLD_GroupToken         = 0x0,
                            PLD_GroupPosition      = 0x0,
                            PLD_Bay                = 0x0,
                            PLD_Ejectable          = 0x1,
                            PLD_EjectRequired      = 0x1,
                            PLD_CabinetNumber      = 0x0,
                            PLD_CardCageNumber     = 0x0,
                            PLD_Reference          = 0x0,
                            PLD_Rotation           = 0x0,
                            PLD_Order              = 0x0)
)  // _PLD: Physical Location of Device
                    }

                    Device (PRT6)
                    {
                        Name (_ADR, 0x06)  // _ADR: Address
                        Name (_UPC, Package (0x04)  // _UPC: USB Port Capabilities
                        {
                            0xFF, 
                            Zero, 
                            Zero, 
                            Zero
                        })
                        Name (_PLD, ToPLD (
                            PLD_Revision           = 0x1,
                            PLD_IgnoreColor        = 0x1,
                            PLD_Red                = 0x0,
                            PLD_Green              = 0x0,
                            PLD_Blue               = 0x0,
                            PLD_Width              = 0x0,
                            PLD_Height             = 0x0,
                            PLD_UserVisible        = 0x0,
                            PLD_Dock               = 0x0,
                            PLD_Lid                = 0x0,
                            PLD_Panel              = "FRONT",
                            PLD_VerticalPosition   = "LOWER",
                            PLD_HorizontalPosition = "LEFT",
                            PLD_Shape              = "HORIZONTALRECTANGLE",
                            PLD_GroupOrientation   = 0x0,
                            PLD_GroupToken         = 0x0,
                            PLD_GroupPosition      = 0x0,
                            PLD_Bay                = 0x0,
                            PLD_Ejectable          = 0x1,
                            PLD_EjectRequired      = 0x1,
                            PLD_CabinetNumber      = 0x0,
                            PLD_CardCageNumber     = 0x0,
                            PLD_Reference          = 0x0,
                            PLD_Rotation           = 0x0,
                            PLD_Order              = 0x0)
)  // _PLD: Physical Location of Device
                    }

                    Device (PRT7)
                    {
                        Name (_ADR, 0x07)  // _ADR: Address
                        Name (_UPC, Package (0x04)  // _UPC: USB Port Capabilities
                        {
                            0xFF, 
                            Zero, 
                            Zero, 
                            Zero
                        })
                        Name (_PLD, ToPLD (
                            PLD_Revision           = 0x1,
                            PLD_IgnoreColor        = 0x1,
                            PLD_Red                = 0x0,
                            PLD_Green              = 0x0,
                            PLD_Blue               = 0x0,
                            PLD_Width              = 0x0,
                            PLD_Height             = 0x0,
                            PLD_UserVisible        = 0x0,
                            PLD_Dock               = 0x0,
                            PLD_Lid                = 0x0,
                            PLD_Panel              = "FRONT",
                            PLD_VerticalPosition   = "LOWER",
                            PLD_HorizontalPosition = "LEFT",
                            PLD_Shape              = "HORIZONTALRECTANGLE",
                            PLD_GroupOrientation   = 0x0,
                            PLD_GroupToken         = 0x0,
                            PLD_GroupPosition      = 0x0,
                            PLD_Bay                = 0x0,
                            PLD_Ejectable          = 0x1,
                            PLD_EjectRequired      = 0x1,
                            PLD_CabinetNumber      = 0x0,
                            PLD_CardCageNumber     = 0x0,
                            PLD_Reference          = 0x0,
                            PLD_Rotation           = 0x0,
                            PLD_Order              = 0x0)
)  // _PLD: Physical Location of Device
                    }

                    Device (PRT8)
                    {
                        Name (_ADR, 0x08)  // _ADR: Address
                        Name (_UPC, Package (0x04)  // _UPC: USB Port Capabilities
                        {
                            0xFF, 
                            Zero, 
                            Zero, 
                            Zero
                        })
                        Name (_PLD, ToPLD (
                            PLD_Revision           = 0x1,
                            PLD_IgnoreColor        = 0x1,
                            PLD_Red                = 0x0,
                            PLD_Green              = 0x0,
                            PLD_Blue               = 0x0,
                            PLD_Width              = 0x0,
                            PLD_Height             = 0x0,
                            PLD_UserVisible        = 0x0,
                            PLD_Dock               = 0x0,
                            PLD_Lid                = 0x0,
                            PLD_Panel              = "FRONT",
                            PLD_VerticalPosition   = "LOWER",
                            PLD_HorizontalPosition = "LEFT",
                            PLD_Shape              = "HORIZONTALRECTANGLE",
                            PLD_GroupOrientation   = 0x0,
                            PLD_GroupToken         = 0x0,
                            PLD_GroupPosition      = 0x0,
                            PLD_Bay                = 0x0,
                            PLD_Ejectable          = 0x1,
                            PLD_EjectRequired      = 0x1,
                            PLD_CabinetNumber      = 0x0,
                            PLD_CardCageNumber     = 0x0,
                            PLD_Reference          = 0x0,
                            PLD_Rotation           = 0x0,
                            PLD_Order              = 0x0)
)  // _PLD: Physical Location of Device
                    }
                }

                Method (_PRW, 0, NotSerialized)  // _PRW: Power Resources for Wake
                {
                    Return (GPRW (0x0D, 0x03))
                }
            }
        }

        Scope (\_GPE)
        {
            Method (_L0B, 0, NotSerialized)  // _Lxx: Level-Triggered GPE, xx=0x00-0xFF
            {
                Notify (\_SB.PCI0.P0P1, 0x02) // Device Wake
                Notify (\_SB.PWRB, 0x02) // Device Wake
            }

            Method (_L09, 0, NotSerialized)  // _Lxx: Level-Triggered GPE, xx=0x00-0xFF
            {
                Notify (\_SB.PCI0.P0P4, 0x02) // Device Wake
                Notify (\_SB.PCI0.P0P5, 0x02) // Device Wake
                Notify (\_SB.PCI0.P0P6, 0x02) // Device Wake
                Notify (\_SB.PCI0.P0P7, 0x02) // Device Wake
                Notify (\_SB.PCI0.P0P8, 0x02) // Device Wake
                Notify (\_SB.PCI0.P0P9, 0x02) // Device Wake
                Notify (\_SB.PWRB, 0x02) // Device Wake
            }

            Method (_L0D, 0, NotSerialized)  // _Lxx: Level-Triggered GPE, xx=0x00-0xFF
            {
                Notify (\_SB.PCI0.P0P4.GBE, 0x02) // Device Wake
                Notify (\_SB.PCI0.EUSB, 0x02) // Device Wake
                Notify (\_SB.PWRB, 0x02) // Device Wake
            }

            Method (_L03, 0, NotSerialized)  // _Lxx: Level-Triggered GPE, xx=0x00-0xFF
            {
                Notify (\_SB.PCI0.USB0, 0x02) // Device Wake
                Notify (\_SB.PWRB, 0x02) // Device Wake
            }

            Method (_L04, 0, NotSerialized)  // _Lxx: Level-Triggered GPE, xx=0x00-0xFF
            {
                Notify (\_SB.PCI0.USB1, 0x02) // Device Wake
                Notify (\_SB.PWRB, 0x02) // Device Wake
            }

            Method (_L0C, 0, NotSerialized)  // _Lxx: Level-Triggered GPE, xx=0x00-0xFF
            {
                Notify (\_SB.PCI0.USB2, 0x02) // Device Wake
                Notify (\_SB.PWRB, 0x02) // Device Wake
            }

            Method (_L0E, 0, NotSerialized)  // _Lxx: Level-Triggered GPE, xx=0x00-0xFF
            {
                Notify (\_SB.PCI0.USB3, 0x02) // Device Wake
                Notify (\_SB.PWRB, 0x02) // Device Wake
            }
        }

        Device (PWRB)
        {
            Name (_HID, EisaId ("PNP0C0C") /* Power Button Device */)  // _HID: Hardware ID
            Name (_UID, 0xAA)  // _UID: Unique ID
            Name (_STA, 0x0B)  // _STA: Status
        }
    }

    OperationRegion (_SB.PCI0.SBRG.PIX0, PCI_Config, 0x60, 0x0C)
    Field (\_SB.PCI0.SBRG.PIX0, ByteAcc, NoLock, Preserve)
    {
        PIRA,   8, 
        PIRB,   8, 
        PIRC,   8, 
        PIRD,   8, 
        Offset (0x08), 
        PIRE,   8, 
        PIRF,   8, 
        PIRG,   8, 
        PIRH,   8
    }

    Scope (_SB)
    {
        Name (BUFA, ResourceTemplate ()
        {
            IRQ (Level, ActiveLow, Shared, )
                {15}
        })
        CreateWordField (BUFA, One, IRA0)
        Device (LNKA)
        {
            Name (_HID, EisaId ("PNP0C0F") /* PCI Interrupt Link Device */)  // _HID: Hardware ID
            Name (_UID, One)  // _UID: Unique ID
            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                Local0 = (PIRA & 0x80)
                If (Local0)
                {
                    Return (0x09)
                }
                Else
                {
                    Return (0x0B)
                }
            }

            Method (_PRS, 0, NotSerialized)  // _PRS: Possible Resource Settings
            {
                Return (PRSA) /* \_SB_.PRSA */
            }

            Method (_DIS, 0, NotSerialized)  // _DIS: Disable Device
            {
                PIRA |= 0x80
            }

            Method (_CRS, 0, NotSerialized)  // _CRS: Current Resource Settings
            {
                Local0 = (PIRA & 0x0F)
                IRA0 = (One << Local0)
                Return (BUFA) /* \_SB_.BUFA */
            }

            Method (_SRS, 1, NotSerialized)  // _SRS: Set Resource Settings
            {
                CreateWordField (Arg0, One, IRA)
                FindSetRightBit (IRA, Local0)
                Local0--
                PIRA = Local0
            }
        }

        Device (LNKB)
        {
            Name (_HID, EisaId ("PNP0C0F") /* PCI Interrupt Link Device */)  // _HID: Hardware ID
            Name (_UID, 0x02)  // _UID: Unique ID
            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                Local0 = (PIRB & 0x80)
                If (Local0)
                {
                    Return (0x09)
                }
                Else
                {
                    Return (0x0B)
                }
            }

            Method (_PRS, 0, NotSerialized)  // _PRS: Possible Resource Settings
            {
                Return (PRSB) /* \_SB_.PRSB */
            }

            Method (_DIS, 0, NotSerialized)  // _DIS: Disable Device
            {
                PIRB |= 0x80
            }

            Method (_CRS, 0, NotSerialized)  // _CRS: Current Resource Settings
            {
                Local0 = (PIRB & 0x0F)
                IRA0 = (One << Local0)
                Return (BUFA) /* \_SB_.BUFA */
            }

            Method (_SRS, 1, NotSerialized)  // _SRS: Set Resource Settings
            {
                CreateWordField (Arg0, One, IRA)
                FindSetRightBit (IRA, Local0)
                Local0--
                PIRB = Local0
            }
        }

        Device (LNKC)
        {
            Name (_HID, EisaId ("PNP0C0F") /* PCI Interrupt Link Device */)  // _HID: Hardware ID
            Name (_UID, 0x03)  // _UID: Unique ID
            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                Local0 = (PIRC & 0x80)
                If (Local0)
                {
                    Return (0x09)
                }
                Else
                {
                    Return (0x0B)
                }
            }

            Method (_PRS, 0, NotSerialized)  // _PRS: Possible Resource Settings
            {
                Return (PRSC) /* \_SB_.PRSC */
            }

            Method (_DIS, 0, NotSerialized)  // _DIS: Disable Device
            {
                PIRC |= 0x80
            }

            Method (_CRS, 0, NotSerialized)  // _CRS: Current Resource Settings
            {
                Local0 = (PIRC & 0x0F)
                IRA0 = (One << Local0)
                Return (BUFA) /* \_SB_.BUFA */
            }

            Method (_SRS, 1, NotSerialized)  // _SRS: Set Resource Settings
            {
                CreateWordField (Arg0, One, IRA)
                FindSetRightBit (IRA, Local0)
                Local0--
                PIRC = Local0
            }
        }

        Device (LNKD)
        {
            Name (_HID, EisaId ("PNP0C0F") /* PCI Interrupt Link Device */)  // _HID: Hardware ID
            Name (_UID, 0x04)  // _UID: Unique ID
            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                Local0 = (PIRD & 0x80)
                If (Local0)
                {
                    Return (0x09)
                }
                Else
                {
                    Return (0x0B)
                }
            }

            Method (_PRS, 0, NotSerialized)  // _PRS: Possible Resource Settings
            {
                Return (PRSD) /* \_SB_.PRSD */
            }

            Method (_DIS, 0, NotSerialized)  // _DIS: Disable Device
            {
                PIRD |= 0x80
            }

            Method (_CRS, 0, NotSerialized)  // _CRS: Current Resource Settings
            {
                Local0 = (PIRD & 0x0F)
                IRA0 = (One << Local0)
                Return (BUFA) /* \_SB_.BUFA */
            }

            Method (_SRS, 1, NotSerialized)  // _SRS: Set Resource Settings
            {
                CreateWordField (Arg0, One, IRA)
                FindSetRightBit (IRA, Local0)
                Local0--
                PIRD = Local0
            }
        }

        Device (LNKE)
        {
            Name (_HID, EisaId ("PNP0C0F") /* PCI Interrupt Link Device */)  // _HID: Hardware ID
            Name (_UID, 0x05)  // _UID: Unique ID
            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                Local0 = (PIRE & 0x80)
                If (Local0)
                {
                    Return (0x09)
                }
                Else
                {
                    Return (0x0B)
                }
            }

            Method (_PRS, 0, NotSerialized)  // _PRS: Possible Resource Settings
            {
                Return (PRSE) /* \_SB_.PRSE */
            }

            Method (_DIS, 0, NotSerialized)  // _DIS: Disable Device
            {
                PIRE |= 0x80
            }

            Method (_CRS, 0, NotSerialized)  // _CRS: Current Resource Settings
            {
                Local0 = (PIRE & 0x0F)
                IRA0 = (One << Local0)
                Return (BUFA) /* \_SB_.BUFA */
            }

            Method (_SRS, 1, NotSerialized)  // _SRS: Set Resource Settings
            {
                CreateWordField (Arg0, One, IRA)
                FindSetRightBit (IRA, Local0)
                Local0--
                PIRE = Local0
            }
        }

        Device (LNKF)
        {
            Name (_HID, EisaId ("PNP0C0F") /* PCI Interrupt Link Device */)  // _HID: Hardware ID
            Name (_UID, 0x06)  // _UID: Unique ID
            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                Local0 = (PIRF & 0x80)
                If (Local0)
                {
                    Return (0x09)
                }
                Else
                {
                    Return (0x0B)
                }
            }

            Method (_PRS, 0, NotSerialized)  // _PRS: Possible Resource Settings
            {
                Return (PRSF) /* \_SB_.PRSF */
            }

            Method (_DIS, 0, NotSerialized)  // _DIS: Disable Device
            {
                PIRF |= 0x80
            }

            Method (_CRS, 0, NotSerialized)  // _CRS: Current Resource Settings
            {
                Local0 = (PIRF & 0x0F)
                IRA0 = (One << Local0)
                Return (BUFA) /* \_SB_.BUFA */
            }

            Method (_SRS, 1, NotSerialized)  // _SRS: Set Resource Settings
            {
                CreateWordField (Arg0, One, IRA)
                FindSetRightBit (IRA, Local0)
                Local0--
                PIRF = Local0
            }
        }

        Device (LNKG)
        {
            Name (_HID, EisaId ("PNP0C0F") /* PCI Interrupt Link Device */)  // _HID: Hardware ID
            Name (_UID, 0x07)  // _UID: Unique ID
            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                Local0 = (PIRG & 0x80)
                If (Local0)
                {
                    Return (0x09)
                }
                Else
                {
                    Return (0x0B)
                }
            }

            Method (_PRS, 0, NotSerialized)  // _PRS: Possible Resource Settings
            {
                Return (PRSG) /* \_SB_.PRSG */
            }

            Method (_DIS, 0, NotSerialized)  // _DIS: Disable Device
            {
                PIRG |= 0x80
            }

            Method (_CRS, 0, NotSerialized)  // _CRS: Current Resource Settings
            {
                Local0 = (PIRG & 0x0F)
                IRA0 = (One << Local0)
                Return (BUFA) /* \_SB_.BUFA */
            }

            Method (_SRS, 1, NotSerialized)  // _SRS: Set Resource Settings
            {
                CreateWordField (Arg0, One, IRA)
                FindSetRightBit (IRA, Local0)
                Local0--
                PIRG = Local0
            }
        }

        Device (LNKH)
        {
            Name (_HID, EisaId ("PNP0C0F") /* PCI Interrupt Link Device */)  // _HID: Hardware ID
            Name (_UID, 0x08)  // _UID: Unique ID
            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                Local0 = (PIRH & 0x80)
                If (Local0)
                {
                    Return (0x09)
                }
                Else
                {
                    Return (0x0B)
                }
            }

            Method (_PRS, 0, NotSerialized)  // _PRS: Possible Resource Settings
            {
                Return (PRSH) /* \_SB_.PRSH */
            }

            Method (_DIS, 0, NotSerialized)  // _DIS: Disable Device
            {
                PIRH |= 0x80
            }

            Method (_CRS, 0, NotSerialized)  // _CRS: Current Resource Settings
            {
                Local0 = (PIRH & 0x0F)
                IRA0 = (One << Local0)
                Return (BUFA) /* \_SB_.BUFA */
            }

            Method (_SRS, 1, NotSerialized)  // _SRS: Set Resource Settings
            {
                CreateWordField (Arg0, One, IRA)
                FindSetRightBit (IRA, Local0)
                Local0--
                PIRH = Local0
            }
        }
    }

    Method (SCMD, 4, NotSerialized)
    {
        OperationRegion (SMRG, SystemIO, SMBS, 0x10)
        Field (SMRG, ByteAcc, NoLock, Preserve)
        {
            HSTS,   8, 
            SSTS,   8, 
            HSTC,   8, 
            HCMD,   8, 
            HADR,   8, 
            HDT0,   8, 
            HDT1,   8, 
            BLKD,   8
        }

        Field (SMRG, ByteAcc, NoLock, Preserve)
        {
            Offset (0x05), 
            HDTW,   16
        }

        Local0 = 0x05
        While (Local0)
        {
            HADR = Arg0
            HCMD = Arg1
            HDTW = Arg2
            HSTS = 0xFF
            HSTC = Arg3
            Local7 = 0xFF
            While (Local7)
            {
                Local7--
                If ((HSTS & 0x02))
                {
                    Local7 = Zero
                    Local0 = One
                }
            }

            Local0--
        }

        If ((HSTS & 0x02))
        {
            Return (HDTW) /* \SCMD.HDTW */
        }
        Else
        {
            Return (Ones)
        }
    }

    Method (SBYT, 2, NotSerialized)
    {
        SCMD (Arg0, Arg1, Zero, 0x44)
    }

    Method (WBYT, 3, NotSerialized)
    {
        SCMD (Arg0, Arg1, Arg2, 0x48)
    }

    Method (WWRD, 3, NotSerialized)
    {
        SCMD (Arg0, Arg1, Arg2, 0x4C)
    }

    Method (RSBT, 2, NotSerialized)
    {
        Arg0 |= One
        Return (SCMD (Arg0, Arg1, Zero, 0x44))
    }

    Method (RBYT, 2, NotSerialized)
    {
        Arg0 |= One
        Return (SCMD (Arg0, Arg1, Zero, 0x48))
    }

    Method (RWRD, 2, NotSerialized)
    {
        Arg0 |= One
        Return (SCMD (Arg0, Arg1, Zero, 0x4C))
    }

    Scope (_SB)
    {
        Name (XCPD, Zero)
        Name (XNPT, One)
        Name (XCAP, 0x02)
        Name (XDCP, 0x04)
        Name (XDCT, 0x08)
        Name (XDST, 0x0A)
        Name (XLCP, 0x0C)
        Name (XLCT, 0x10)
        Name (XLST, 0x12)
        Name (XSCP, 0x14)
        Name (XSCT, 0x18)
        Name (XSST, 0x1A)
        Name (XRCT, 0x1C)
        Mutex (MUTE, 0x00)
        Method (RBPE, 1, NotSerialized)
        {
            Acquire (MUTE, 0x03E8)
            Local0 = (Arg0 + PCIB) /* \PCIB */
            OperationRegion (PCFG, SystemMemory, Local0, One)
            Field (PCFG, ByteAcc, NoLock, Preserve)
            {
                XCFG,   8
            }

            Release (MUTE)
            Return (XCFG) /* \_SB_.RBPE.XCFG */
        }

        Method (RWPE, 1, NotSerialized)
        {
            Acquire (MUTE, 0x03E8)
            Arg0 &= 0xFFFFFFFE
            Local0 = (Arg0 + PCIB) /* \PCIB */
            OperationRegion (PCFG, SystemMemory, Local0, 0x02)
            Field (PCFG, WordAcc, NoLock, Preserve)
            {
                XCFG,   16
            }

            Release (MUTE)
            Return (XCFG) /* \_SB_.RWPE.XCFG */
        }

        Method (RDPE, 1, NotSerialized)
        {
            Acquire (MUTE, 0x03E8)
            Arg0 &= 0xFFFFFFFC
            Local0 = (Arg0 + PCIB) /* \PCIB */
            OperationRegion (PCFG, SystemMemory, Local0, 0x04)
            Field (PCFG, DWordAcc, NoLock, Preserve)
            {
                XCFG,   32
            }

            Release (MUTE)
            Return (XCFG) /* \_SB_.RDPE.XCFG */
        }

        Method (WBPE, 2, NotSerialized)
        {
            Acquire (MUTE, 0x0FFF)
            Local0 = (Arg0 + PCIB) /* \PCIB */
            OperationRegion (PCFG, SystemMemory, Local0, One)
            Field (PCFG, ByteAcc, NoLock, Preserve)
            {
                XCFG,   8
            }

            XCFG = Arg1
            Release (MUTE)
        }

        Method (WWPE, 2, NotSerialized)
        {
            Acquire (MUTE, 0x03E8)
            Arg0 &= 0xFFFFFFFE
            Local0 = (Arg0 + PCIB) /* \PCIB */
            OperationRegion (PCFG, SystemMemory, Local0, 0x02)
            Field (PCFG, WordAcc, NoLock, Preserve)
            {
                XCFG,   16
            }

            XCFG = Arg1
            Release (MUTE)
        }

        Method (WDPE, 2, NotSerialized)
        {
            Acquire (MUTE, 0x03E8)
            Arg0 &= 0xFFFFFFFC
            Local0 = (Arg0 + PCIB) /* \PCIB */
            OperationRegion (PCFG, SystemMemory, Local0, 0x04)
            Field (PCFG, DWordAcc, NoLock, Preserve)
            {
                XCFG,   32
            }

            XCFG = Arg1
            Release (MUTE)
        }

        Method (RWDP, 3, NotSerialized)
        {
            Acquire (MUTE, 0x03E8)
            Arg0 &= 0xFFFFFFFC
            Local0 = (Arg0 + PCIB) /* \PCIB */
            OperationRegion (PCFG, SystemMemory, Local0, 0x04)
            Field (PCFG, DWordAcc, NoLock, Preserve)
            {
                XCFG,   32
            }

            Local1 = (XCFG & Arg2)
            XCFG = (Local1 | Arg1)
            Release (MUTE)
        }

        Method (RPME, 1, NotSerialized)
        {
            Local0 = (Arg0 + 0x84)
            Local1 = RDPE (Local0)
            If ((Local1 == Ones))
            {
                Return (Zero)
            }
            Else
            {
                If ((Local1 && 0x00010000))
                {
                    WDPE (Local0, (Local1 & 0x00010000))
                    Return (One)
                }

                Return (Zero)
            }
        }
    }

    Scope (_SB.PCI0)
    {
        Method (_OSC, 4, NotSerialized)  // _OSC: Operating System Capabilities
        {
            Name (SUPP, Zero)
            Name (CTRL, Zero)
            CreateDWordField (Arg3, Zero, CDW1)
            CreateDWordField (Arg3, 0x04, CDW2)
            CreateDWordField (Arg3, 0x08, CDW3)
            If ((Arg0 == ToUUID ("33db4d5b-1ff7-401c-9657-7441c03dd766") /* PCI Host Bridge Device */))
            {
                SUPP = CDW2 /* \_SB_.PCI0._OSC.CDW2 */
                CTRL = CDW3 /* \_SB_.PCI0._OSC.CDW3 */
                If (((SUPP & 0x16) != 0x16))
                {
                    CTRL &= 0x1E
                }

                If (!PEHP)
                {
                    CTRL &= 0x1E
                }

                If (!SHPC)
                {
                    CTRL &= 0x1D
                }

                If (!PEPM)
                {
                    CTRL &= 0x1B
                }

                If (!PEER)
                {
                    CTRL &= 0x15
                }

                If (!PECS)
                {
                    CTRL &= 0x0F
                }

                If (~(CDW1 & One))
                {
                    If ((CTRL & One)){}
                    If ((CTRL & 0x04)){}
                    If ((CTRL & 0x10)){}
                }

                If ((Arg1 != One))
                {
                    CDW1 |= 0x08
                }

                If ((CDW3 != CTRL))
                {
                    CDW1 |= 0x10
                }

                CDW3 = CTRL /* \_SB_.PCI0._OSC.CTRL */
                Return (Arg3)
            }
            Else
            {
                CDW1 |= 0x04
                Return (Arg3)
            }
        }
    }

    Scope (_SB.PCI0)
    {
        Device (GFX0)
        {
            Name (_ADR, 0x00020000)  // _ADR: Address
            OperationRegion (IGDM, SystemMemory, 0x7F6AE0E4, 0x2000)
            Field (IGDM, AnyAcc, NoLock, Preserve)
            {
                SIGN,   128, 
                SIZE,   32, 
                OVER,   32, 
                SVER,   256, 
                VVER,   128, 
                GVER,   128, 
                MBOX,   32, 
                DMOD,   32, 
                Offset (0xE0), 
                KSV0,   32, 
                KSV1,   8, 
                Offset (0xF0), 
                IBTT,   8, 
                IPSC,   2, 
                IPAT,   4, 
                Offset (0xF2), 
                IBIA,   3, 
                IBLC,   2, 
                    ,   1, 
                ITVF,   4, 
                ITVM,   4, 
                Offset (0xF4), 
                IDVM,   1, 
                IDVS,   2, 
                ISSC,   1, 
                PAVP,   4, 
                CSTE,   16, 
                NSTE,   16, 
                Offset (0x100), 
                DRDY,   32, 
                CSTS,   32, 
                CEVT,   32, 
                Offset (0x120), 
                DIDL,   32, 
                DDL2,   32, 
                DDL3,   32, 
                DDL4,   32, 
                DDL5,   32, 
                DDL6,   32, 
                DDL7,   32, 
                DDL8,   32, 
                CPDL,   32, 
                CPL2,   32, 
                CPL3,   32, 
                CPL4,   32, 
                CPL5,   32, 
                CPL6,   32, 
                CPL7,   32, 
                CPL8,   32, 
                CADL,   32, 
                CAL2,   32, 
                CAL3,   32, 
                CAL4,   32, 
                CAL5,   32, 
                CAL6,   32, 
                CAL7,   32, 
                CAL8,   32, 
                NADL,   32, 
                NDL2,   32, 
                NDL3,   32, 
                NDL4,   32, 
                NDL5,   32, 
                NDL6,   32, 
                NDL7,   32, 
                NDL8,   32, 
                ASLP,   32, 
                TIDX,   32, 
                CHPD,   32, 
                CLID,   32, 
                CDCK,   32, 
                SXSW,   32, 
                EVTS,   32, 
                CNOT,   32, 
                NRDY,   32, 
                Offset (0x200), 
                SCIE,   1, 
                GEFC,   4, 
                GXFC,   3, 
                GESF,   8, 
                Offset (0x204), 
                PARM,   32, 
                DSLP,   32, 
                Offset (0x300), 
                ARDY,   32, 
                ASLC,   32, 
                TCHE,   32, 
                ALSI,   32, 
                BCLP,   32, 
                PFIT,   32, 
                CBLV,   32, 
                BCLM,   320, 
                CPFM,   32, 
                EPFM,   32, 
                PLUT,   592, 
                PFMB,   32, 
                DDCV,   32, 
                Offset (0x400), 
                GVD1,   49152, 
                PHED,   32, 
                BDDC,   2048
            }

            OperationRegion (TCOI, SystemIO, TOBS, 0x08)
            Field (TCOI, WordAcc, NoLock, Preserve)
            {
                Offset (0x04), 
                    ,   9, 
                SCIS,   1, 
                Offset (0x06)
            }

            Name (DBTB, Package (0x15)
            {
                Zero, 
                0x07, 
                0x38, 
                0x01C0, 
                0x0E00, 
                0x3F, 
                0x01C7, 
                0x0E07, 
                0x01F8, 
                0x0E38, 
                0x0FC0, 
                Zero, 
                Zero, 
                Zero, 
                Zero, 
                Zero, 
                0x7000, 
                0x7007, 
                0x7038, 
                0x71C0, 
                0x7E00
            })
            Method (GSCI, 0, Serialized)
            {
                If ((GEFC == 0x04))
                {
                    GXFC = GBDA ()
                }

                If ((GEFC == 0x06))
                {
                    GXFC = SBCB ()
                }

                GEFC = Zero
                SCIS = One
                GSSE = Zero
                SCIE = Zero
                Return (Zero)
            }

            Method (GBDA, 0, Serialized)
            {
                If ((GESF == Zero))
                {
                    If ((DVMT >= 0x05))
                    {
                        PARM = 0x0679
                    }
                    Else
                    {
                        PARM = 0x0279
                    }

                    GESF = Zero
                    Return (SUCC) /* \SUCC */
                }

                If ((GESF == One))
                {
                    PARM = 0x0240
                    GESF = Zero
                    Return (SUCC) /* \SUCC */
                }

                If ((GESF == 0x04))
                {
                    PARM &= 0xEFFF0000
                    PARM &= (DerefOf (DBTB [IBTT]) << 0x10)
                    PARM |= IBTT /* \_SB_.PCI0.GFX0.PARM */
                    GESF = Zero
                    Return (SUCC) /* \SUCC */
                }

                If ((GESF == 0x05))
                {
                    PARM = IPSC /* \_SB_.PCI0.GFX0.IPSC */
                    PARM |= (IPAT << 0x08)
                    PARM += 0x0100
                    PARM |= (LIDS << 0x10)
                    PARM += 0x00010000
                    PARM |= (IBIA << 0x14)
                    GESF = Zero
                    Return (SUCC) /* \SUCC */
                }

                If ((GESF == 0x06))
                {
                    PARM = ITVF /* \_SB_.PCI0.GFX0.ITVF */
                    PARM |= (ITVM << 0x04)
                    GESF = Zero
                    Return (SUCC) /* \SUCC */
                }

                If ((GESF == 0x07))
                {
                    If ((DVMT >= 0x05))
                    {
                        PARM = GIVD /* \_SB_.PCI0.GFX0.GIVD */
                        PARM ^= One
                        PARM |= (GMFN << One)
                        PARM |= 0x1800
                        PARM |= (IDVS << 0x11)
                        PARM |= (CDCT << 0x15) /* \_SB_.PCI0.GFX0.PARM */
                    }
                    Else
                    {
                        Name (MEMS, 0x0D)
                        PARM = GIVD /* \_SB_.PCI0.GFX0.GIVD */
                        PARM ^= One
                        PARM |= (GMFN << One)
                        PARM |= 0x1000
                        PARM |= (CDCT << 0x15) /* \_SB_.PCI0.GFX0.PARM */
                        If ((IDVM == One))
                        {
                            MEMS = 0x11
                        }

                        If ((TASM < M512))
                        {
                            PARM |= (One << MEMS)
                        }
                        ElseIf ((TASM < M1GB))
                        {
                            If ((IDVS < 0x03))
                            {
                                PARM |= (IDVS << MEMS)
                            }
                            Else
                            {
                                PARM |= (0x02 << MEMS)
                            }
                        }
                        Else
                        {
                            PARM |= (IDVS << MEMS)
                        }
                    }

                    GESF = One
                    Return (SUCC) /* \SUCC */
                }

                If ((GESF == 0x0A))
                {
                    PARM = Zero
                    If (ISSC)
                    {
                        PARM |= 0x03
                    }

                    GESF = Zero
                    Return (SUCC) /* \SUCC */
                }

                If ((GESF == 0x0B))
                {
                    PARM = KSV0 /* \_SB_.PCI0.GFX0.KSV0 */
                    GESF = KSV1 /* \_SB_.PCI0.GFX0.KSV1 */
                    Return (SUCC) /* \SUCC */
                }

                GESF = Zero
                Return (CRIT) /* \CRIT */
            }

            Method (SBCB, 0, Serialized)
            {
                If ((GESF == Zero))
                {
                    PARM = 0x20
                    GESF = Zero
                    Return (SUCC) /* \SUCC */
                }

                If ((GESF == One))
                {
                    GESF = Zero
                    PARM = Zero
                    Return (SUCC) /* \SUCC */
                }

                If ((GESF == 0x03))
                {
                    GESF = Zero
                    PARM = Zero
                    Return (SUCC) /* \SUCC */
                }

                If ((GESF == 0x04))
                {
                    GESF = Zero
                    PARM = Zero
                    Return (SUCC) /* \SUCC */
                }

                If ((GESF == 0x05))
                {
                    GESF = Zero
                    PARM = Zero
                    Return (SUCC) /* \SUCC */
                }

                If ((GESF == 0x06))
                {
                    ITVF = (PARM & 0x0F)
                    ITVM = ((PARM & 0xF0) >> 0x04)
                    GESF = Zero
                    PARM = Zero
                    Return (SUCC) /* \SUCC */
                }

                If ((GESF == 0x07))
                {
                    If ((PARM == Zero))
                    {
                        Local0 = CLID /* \_SB_.PCI0.GFX0.CLID */
                        If ((0x80000000 & Local0))
                        {
                            CLID &= 0x0F
                            GLID (CLID)
                        }
                    }

                    GESF = Zero
                    PARM = Zero
                    Return (SUCC) /* \SUCC */
                }

                If ((GESF == 0x08))
                {
                    GESF = Zero
                    PARM = Zero
                    Return (SUCC) /* \SUCC */
                }

                If ((GESF == 0x09))
                {
                    IBTT = (PARM & 0xFF)
                    GESF = Zero
                    PARM = Zero
                    Return (SUCC) /* \SUCC */
                }

                If ((GESF == 0x0A))
                {
                    IPSC = (PARM & 0xFF)
                    If (((PARM >> 0x08) & 0xFF))
                    {
                        IPAT = ((PARM >> 0x08) & 0xFF)
                        IPAT--
                    }

                    IBIA = ((PARM >> 0x14) & 0x07)
                    GESF = Zero
                    PARM = Zero
                    Return (SUCC) /* \SUCC */
                }

                If ((GESF == 0x0B))
                {
                    If ((((PARM >> 0x0B) & 0x03) >= 0x02))
                    {
                        Local0 = ((PARM >> 0x0D) & 0x0F)
                        Local1 = ((PARM >> 0x11) & 0x0F)
                        If (Local0)
                        {
                            IDVM = Zero
                            IDVS = Local0
                        }

                        If (Local1)
                        {
                            IDVM = One
                            IDVS = Local1
                        }
                    }

                    GESF = Zero
                    PARM = Zero
                    Return (SUCC) /* \SUCC */
                }

                If ((GESF == 0x10))
                {
                    GESF = Zero
                    PARM = Zero
                    Return (SUCC) /* \SUCC */
                }

                If ((GESF == 0x11))
                {
                    PARM = (LIDS << 0x08)
                    PARM += 0x0100
                    GESF = Zero
                    Return (SUCC) /* \SUCC */
                }

                If ((GESF == 0x12))
                {
                    If ((PARM & One))
                    {
                        If (((PARM >> One) == One))
                        {
                            ISSC = One
                        }
                        Else
                        {
                            GESF = Zero
                            Return (CRIT) /* \CRIT */
                        }
                    }
                    Else
                    {
                        ISSC = Zero
                    }

                    GESF = Zero
                    PARM = Zero
                    Return (SUCC) /* \SUCC */
                }

                If ((GESF == 0x13))
                {
                    GESF = Zero
                    PARM = Zero
                    Return (SUCC) /* \SUCC */
                }

                If ((DVMT >= 0x05))
                {
                    If ((GESF == 0x14))
                    {
                        PAVP = (PARM & 0x0F)
                        GESF = Zero
                        PARM = Zero
                        Return (SUCC) /* \SUCC */
                    }
                }

                GESF = Zero
                Return (SUCC) /* \SUCC */
            }

            Scope (^^PCI0)
            {
                OperationRegion (MCHP, PCI_Config, 0x40, 0xC0)
                Field (MCHP, AnyAcc, NoLock, Preserve)
                {
                    Offset (0x60), 
                    TASM,   10, 
                    Offset (0x62)
                }
            }

            OperationRegion (IGDP, PCI_Config, 0x40, 0xC0)
            Field (IGDP, AnyAcc, NoLock, Preserve)
            {
                Offset (0x12), 
                    ,   1, 
                GIVD,   1, 
                    ,   2, 
                GUMA,   3, 
                Offset (0x14), 
                    ,   4, 
                GMFN,   1, 
                Offset (0x18), 
                Offset (0x8C), 
                CDCT,   10, 
                Offset (0x8E), 
                Offset (0xA4), 
                ASLE,   8, 
                Offset (0xA8), 
                GSSE,   1, 
                GSSB,   14, 
                GSES,   1, 
                Offset (0xB0), 
                    ,   12, 
                CDVL,   1, 
                Offset (0xB2), 
                Offset (0xB5), 
                LBPC,   8, 
                Offset (0xBC), 
                ASLS,   32
            }

            Name (M512, 0x04)
            Name (M1GB, 0x08)
            Method (PDRD, 0, NotSerialized)
            {
                If (!DRDY)
                {
                    Sleep (ASLP)
                }

                Return (!DRDY)
            }

            Method (PSTS, 0, NotSerialized)
            {
                If ((CSTS > 0x02))
                {
                    Sleep (ASLP)
                }

                Return ((CSTS == 0x03))
            }

            Method (OSYS, 0, NotSerialized)
            {
                Local1 = 0x07D0
                If (CondRefOf (_OSI, Local0))
                {
                    If (_OSI ("Linux"))
                    {
                        Local1 = One
                    }

                    If (_OSI ("Windows 2001"))
                    {
                        Local1 = 0x07D1
                    }

                    If (_OSI ("Windows 2001 SP1"))
                    {
                        Local1 = 0x07D1
                    }

                    If (_OSI ("Windows 2001 SP2"))
                    {
                        Local1 = 0x07D2
                    }

                    If (_OSI ("Windows 2006"))
                    {
                        Local1 = 0x07D6
                    }
                }

                Return (Local1)
            }

            Method (GNOT, 2, NotSerialized)
            {
                If (PDRD ())
                {
                    Return (One)
                }

                CEVT = Arg0
                CSTS = 0x03
                If (((CHPD == Zero) && (Arg1 == Zero)))
                {
                    If (((OSYS () > 0x07D0) || (OSYS () < 0x07D6)))
                    {
                        Notify (PCI0, Arg1)
                    }
                    Else
                    {
                        Notify (GFX0, Arg1)
                    }
                }

                Notify (GFX0, 0x80) // Status Change
                Return (Zero)
            }

            Method (GHDS, 1, NotSerialized)
            {
                TIDX = Arg0
                Return (GNOT (One, Zero))
            }

            Method (GLID, 1, NotSerialized)
            {
                CLID = Arg0
                Return (GNOT (0x02, Zero))
            }

            Method (GDCK, 1, NotSerialized)
            {
                CDCK = Arg0
                Return (GNOT (0x04, Zero))
            }

            Method (PARD, 0, NotSerialized)
            {
                If (!ARDY)
                {
                    Sleep (ASLP)
                }

                Return (!ARDY)
            }

            Method (AINT, 2, NotSerialized)
            {
                If (!(TCHE & (One << Arg0)))
                {
                    Return (One)
                }

                If (PARD ())
                {
                    Return (One)
                }

                If ((Arg0 == 0x02))
                {
                    If (CPFM)
                    {
                        Local0 = (CPFM & 0x0F)
                        Local1 = (EPFM & 0x0F)
                        If ((Local0 == One))
                        {
                            If ((Local1 & 0x06))
                            {
                                PFIT = 0x06
                            }
                            ElseIf ((Local1 & 0x08))
                            {
                                PFIT = 0x08
                            }
                            Else
                            {
                                PFIT = One
                            }
                        }

                        If ((Local0 == 0x06))
                        {
                            If ((Local1 & 0x08))
                            {
                                PFIT = 0x08
                            }
                            ElseIf ((Local1 & One))
                            {
                                PFIT = One
                            }
                            Else
                            {
                                PFIT = 0x06
                            }
                        }

                        If ((Local0 == 0x08))
                        {
                            If ((Local1 & One))
                            {
                                PFIT = One
                            }
                            ElseIf ((Local1 & 0x06))
                            {
                                PFIT = 0x06
                            }
                            Else
                            {
                                PFIT = 0x08
                            }
                        }
                    }
                    Else
                    {
                        PFIT ^= 0x07
                    }

                    PFIT |= 0x80000000
                    ASLC = 0x04
                }
                ElseIf ((Arg0 == One))
                {
                    BCLP = ((Arg1 * 0xFF) / 0x64)
                    BCLP |= 0x80000000
                    ASLC = 0x02
                }
                ElseIf ((Arg0 == Zero))
                {
                    ALSI = Arg1
                    ASLC = One
                }
                Else
                {
                    Return (One)
                }

                LBPC = Zero
                Return (Zero)
            }

            Method (SCIP, 0, NotSerialized)
            {
                If (~GIVD)
                {
                    If ((OVER != Zero))
                    {
                        Return (One)
                    }
                }

                Return (Zero)
            }

            Scope (\_GPE)
            {
                Method (_L06, 0, NotSerialized)  // _Lxx: Level-Triggered GPE, xx=0x00-0xFF
                {
                    \_SB.PCI0.GFX0.GSCI ()
                }
            }

            Name (OPBS, 0xFFFFFF00)
            Method (OPTS, 1, NotSerialized)
            {
                If ((Arg0 == 0x03))
                {
                    OPBS = ASLS /* \_SB_.PCI0.GFX0.ASLS */
                }
            }

            Method (OWAK, 1, NotSerialized)
            {
                If ((Arg0 == 0x03))
                {
                    ASLS = OPBS /* \_SB_.PCI0.GFX0.OPBS */
                    GSES = One
                }
            }
        }
    }

    Scope (_SB.PCI0.SBRG)
    {
        OperationRegion (RXAB, PCI_Config, 0xAB, 0x10)
        Field (RXAB, ByteAcc, NoLock, Preserve)
        {
                ,   2, 
            EBEN,   1, 
            Offset (0x01)
        }
    }

    Scope (_SB)
    {
        Scope (PCI0)
        {
            Name (CRS, ResourceTemplate ()
            {
                WordBusNumber (ResourceProducer, MinFixed, MaxFixed, PosDecode,
                    0x0000,             // Granularity
                    0x0000,             // Range Minimum
                    0x00FF,             // Range Maximum
                    0x0000,             // Translation Offset
                    0x0100,             // Length
                    ,, )
                IO (Decode16,
                    0x0CF8,             // Range Minimum
                    0x0CF8,             // Range Maximum
                    0x01,               // Alignment
                    0x08,               // Length
                    )
                WordIO (ResourceProducer, MinFixed, MaxFixed, PosDecode, EntireRange,
                    0x0000,             // Granularity
                    0x0000,             // Range Minimum
                    0x0CF7,             // Range Maximum
                    0x0000,             // Translation Offset
                    0x0CF8,             // Length
                    ,, , TypeStatic, DenseTranslation)
                WordIO (ResourceProducer, MinFixed, MaxFixed, PosDecode, EntireRange,
                    0x0000,             // Granularity
                    0x0D00,             // Range Minimum
                    0xFFFF,             // Range Maximum
                    0x0000,             // Translation Offset
                    0xF300,             // Length
                    ,, , TypeStatic, DenseTranslation)
                DWordMemory (ResourceProducer, PosDecode, MinFixed, MaxFixed, Cacheable, ReadWrite,
                    0x00000000,         // Granularity
                    0x000A0000,         // Range Minimum
                    0x000BFFFF,         // Range Maximum
                    0x00000000,         // Translation Offset
                    0x00020000,         // Length
                    ,, , AddressRangeMemory, TypeStatic)
                DWordMemory (ResourceProducer, PosDecode, MinFixed, MaxFixed, Cacheable, ReadWrite,
                    0x00000000,         // Granularity
                    0x000C0000,         // Range Minimum
                    0x000DFFFF,         // Range Maximum
                    0x00000000,         // Translation Offset
                    0x00020000,         // Length
                    ,, _Y0D, AddressRangeMemory, TypeStatic)
                DWordMemory (ResourceProducer, PosDecode, MinFixed, MaxFixed, Cacheable, ReadWrite,
                    0x00000000,         // Granularity
                    0x00000000,         // Range Minimum
                    0x00000000,         // Range Maximum
                    0x00000000,         // Translation Offset
                    0x00000000,         // Length
                    ,, _Y0E, AddressRangeMemory, TypeStatic)
                DWordMemory (ResourceProducer, PosDecode, MinFixed, MaxFixed, Cacheable, ReadWrite,
                    0x00000000,         // Granularity
                    0x00000000,         // Range Minimum
                    0x00000000,         // Range Maximum
                    0x00000000,         // Translation Offset
                    0x00000000,         // Length
                    ,, _Y0F, AddressRangeMemory, TypeStatic)
            })
            CreateDWordField (CRS, \_SB.PCI0._Y0D._MIN, MIN5)  // _MIN: Minimum Base Address
            CreateDWordField (CRS, \_SB.PCI0._Y0D._MAX, MAX5)  // _MAX: Maximum Base Address
            CreateDWordField (CRS, \_SB.PCI0._Y0D._LEN, LEN5)  // _LEN: Length
            CreateDWordField (CRS, \_SB.PCI0._Y0E._MIN, MIN6)  // _MIN: Minimum Base Address
            CreateDWordField (CRS, \_SB.PCI0._Y0E._MAX, MAX6)  // _MAX: Maximum Base Address
            CreateDWordField (CRS, \_SB.PCI0._Y0E._LEN, LEN6)  // _LEN: Length
            CreateDWordField (CRS, \_SB.PCI0._Y0F._MIN, MIN7)  // _MIN: Minimum Base Address
            CreateDWordField (CRS, \_SB.PCI0._Y0F._MAX, MAX7)  // _MAX: Maximum Base Address
            CreateDWordField (CRS, \_SB.PCI0._Y0F._LEN, LEN7)  // _LEN: Length
            Method (_CRS, 0, NotSerialized)  // _CRS: Current Resource Settings
            {
                Local0 = MG1L /* \MG1L */
                If (Local0)
                {
                    MIN5 = MG1B /* \MG1B */
                    LEN5 = MG1L /* \MG1L */
                    MAX5 = (MIN5 + Local0--)
                }

                MIN6 = MG2B /* \MG2B */
                LEN6 = MG2L /* \MG2L */
                Local0 = MG2L /* \MG2L */
                MAX6 = (MIN6 + Local0--)
                MIN7 = MG3B /* \MG3B */
                LEN7 = MG3L /* \MG3L */
                Local0 = MG3L /* \MG3L */
                MAX7 = (MIN7 + Local0--)
                Return (CRS) /* \_SB_.PCI0.CRS_ */
            }
        }
    }

    Name (WOTB, Zero)
    Name (WSSB, Zero)
    Name (WAXB, Zero)
    Method (_PTS, 1, NotSerialized)  // _PTS: Prepare To Sleep
    {
        DBG8 = Arg0
        PTS (Arg0)
        WAKP [Zero] = Zero
        WAKP [One] = Zero
        If (((Arg0 == 0x04) && (OSFL () == 0x02)))
        {
            Sleep (0x0BB8)
        }

        WSSB = ASSB /* \ASSB */
        WOTB = AOTB /* \AOTB */
        WAXB = AAXB /* \AAXB */
        ASSB = Arg0
        AOTB = OSFL ()
        OSTP = OSYS ()
        AAXB = Zero
    }

    Method (_WAK, 1, NotSerialized)  // _WAK: Wake
    {
        DBG8 = (Arg0 << 0x04)
        WAK (Arg0)
        If (ASSB)
        {
            ASSB = WSSB /* \WSSB */
            AOTB = WOTB /* \WOTB */
            AAXB = WAXB /* \WAXB */
        }

        If (DerefOf (WAKP [Zero]))
        {
            WAKP [One] = Zero
        }
        Else
        {
            WAKP [One] = Arg0
        }

        Return (WAKP) /* \WAKP */
    }

    Name (_S0, Package (0x04)  // _S0_: S0 System State
    {
        Zero, 
        Zero, 
        Zero, 
        Zero
    })
    If (SS1)
    {
        Name (_S1, Package (0x04)  // _S1_: S1 System State
        {
            One, 
            Zero, 
            Zero, 
            Zero
        })
    }

    If (SS3)
    {
        Name (_S3, Package (0x04)  // _S3_: S3 System State
        {
            0x05, 
            Zero, 
            Zero, 
            Zero
        })
    }

    If (SS4)
    {
        Name (_S4, Package (0x04)  // _S4_: S4 System State
        {
            0x06, 
            Zero, 
            Zero, 
            Zero
        })
    }

    Name (_S5, Package (0x04)  // _S5_: S5 System State
    {
        0x07, 
        Zero, 
        Zero, 
        Zero
    })
    Method (PTS, 1, NotSerialized)
    {
        If (Arg0)
        {
            \_SB.PCI0.NPTS (Arg0)
            \_SB.PCI0.SBRG.SPTS (Arg0)
            \_SB.PCI0.GFX0.OPTS (Arg0)
        }
    }

    Method (WAK, 1, NotSerialized)
    {
        \_SB.PCI0.NWAK (Arg0)
        \_SB.PCI0.SBRG.SWAK (Arg0)
        \_SB.PCI0.GFX0.OWAK (Arg0)
    }
}

