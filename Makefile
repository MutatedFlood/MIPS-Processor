SHELL := /bin/tcsh

ARGS = # external arguments

VLOG = ncverilog
DV = dc_shell -f

CSHRC = cshrc
TB = tb.v
SCMIPS = SingleCycleMIPS
TSMC = tsmc13.v

DESIGNWARE = -y /usr/cad/synopsys/synthesis/cur/dw/sim_ver/ \
+libext+.v +incdir+/usr/cad/synopsys/synthesis/cur/dw/sim_ver/


.PHONY: all
all: syn/build

.PHONY: source
source: $(CSHRC)
	@printf "please run '%s'\n" "source $(CSHRC)"

.PHONY: rtl/% syn/%

rtl/cpu: $(TB) $(SCMIPS).v
	$(VLOG) $(TB) $(SCMIPS).v +define+Baseline +access+r $(ARGS)

syn/build: run.tcl
	$(DV) run.tcl $(ARGS)

syn/cpu: $(TB) $(SCMIPS)_syn.v $(TSMC)
	$(VLOG) $(TB) $(SCMIPS)_syn.v $(TSMC) +define+Baseline+SDF +access+r $(ARGS)

rtl/fpu: $(TB) $(SCMIPS)_FPU.v
	$(VLOG) $(TB) $(SCMIPS)_FPU.v $(DESIGNWARE) +define+Baseline +access+r $(ARGS)

rtl/single: $(TB) $(SCMIPS)_FPU.v
	$(VLOG) $(TB) $(SCMIPS)_FPU.v $(DESIGNWARE) +define+FPU+Single +access+r $(ARGS)

rtl/double: $(TB) $(SCMIPS)_FPU.v
	$(VLOG) $(TB) $(SCMIPS)_FPU.v $(DESIGNWARE) +define+FPU+Double +access+r $(ARGS)

syn/fpu: $(TB) $(SCMIPS)_FPU_syn.v $(TSMC)
	$(VLOG) $(TB) $(SCMIPS)_FPU_syn.v $(TSMC) +define+FPU+Single +access+r $(ARGS)
