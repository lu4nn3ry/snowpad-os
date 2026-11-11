/*
 * cpuid.c - SnowPad OS CPU Identification for Intel Atom N450
 * XNU 1504 (Darwin 10) kernel module for Pineview platform
 *
 * Patch to recognize Intel Atom N450 (Family 6, Model 28)
 * without triggering kernel panic on unsupported CPU.
 */

#include <machine/cpufunc.h>

/* Intel Atom N450 specific IDs */
#define CPUFAMILY_INTEL_ATOM        6
#define CPU_MODEL_ATOM              28
#define CPU_STEP_ATOM_N450          10

/* Original XNU cpuid detection - modified for Atom N450 support */
const char *cpu_id_string = "Intel Atom N450 Pineview";

/*
 * cpuid_identify - Identify CPU type and features
 * Modified to accept Intel Atom N450 without kernel panic
 */
void
cpuid_identify(void)
{
    uint32_t eax, ebx, ecx, edx;
    uint32_t family, model, stepping;

    /* Read basic CPUID information */
    cpuid(0x0, &eax, &ebx, &ecx, &edx);

    /* Extract family, model, and stepping from eax */
    family = (eax >> 8) & 0x0f;
    model = (eax >> 4) & 0x0f;
    stepping = eax & 0x0f;

    /* Check for Intel Atom N450 (Family 6, Model 28) */
    if (family == CPUFAMILY_INTEL_ATOM && model == CPU_MODEL_ATOM) {
        /* Patch: Mark as supported Atom processor */
        printf("[CPU] Intel Atom N450 (Pineview) detected\n");
        printf("[CPU] Family: %d, Model: %d, Stepping: %d\n",
               family, model, stepping);

        /* Enable Atom-specific optimizations */
        set_cpufeature(CPUFEAT_ATOM_N450, TRUE);
        return;
    }

    /* Fallback: Original XNU behavior for other processors */
    if (family == 6) {
        /* Model validation - prevent panic on unsupported models */
        printf("[CPU] Family 6 CPU detected, model %d\n", model);
    }

    /* Default XNU CPU identification */
    printf("[CPU] Standard XNU CPU identification\n");
}

/*
 * cpuid_init - Initialize CPU detection early in boot
 * Called during XNU startup before full kernel initialization
 */
void
cpuid_init(void)
{
    /* Set default CPU type to i386 */
    set_cpu_type(X86_TYPE_I386);

    /* Register Atom N450 detection */
    cpuid_identify();

    /* Initialize cache information */
    cpu_cache_init();
}

/*
 * cpuid_check_family - Verify CPU family is supported
 * Returns TRUE if family is supported, FALSE otherwise
 */
bool
cpuid_check_family(uint32_t family)
{
    /* Atom N450 and later are supported */
    if (family == CPUFAMILY_INTEL_ATOM) {
        return TRUE;
    }
    /* Default XNU supported families */
    if (family == 5 || family == 6 || family == 0x6) {
        return TRUE;
    }
    return FALSE;
}

/* End of cpuid.c */