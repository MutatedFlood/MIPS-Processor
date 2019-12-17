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

.PHONY: all source cpu compile csyn fpu single double fsyn

all: source
	
source: $(CSHRC)
	@printf "please run '%s'\n" "source $(CSHRC)"

cpu: $(TB) $(SCMIPS).v
	$(VLOG) $(TB) $(SCMIPS).v +define+Baseline +access+r $(ARGS)

compile: run.tcl
	$(DV) run.tcl $(ARGS)

csyn: $(TB) $(SCMIPS)_syn.v $(TSMC)
	$(VLOG) $(TB) $(SCMIPS)_syn.v $(TSMC) +define+Baseline+SDF +access+r $(ARGS)

fpu: $(TB) $(SCMIPS)_FPU.v
	$(VLOG) $(TB) $(SCMIPS)_FPU.v $(DESIGNWARE) +define+Baseline +access+r $(ARGS)

single: $(TB) $(SCMIPS)_FPU.v
	$(VLOG) $(TB) $(SCMIPS)_FPU.v $(DESIGNWARE) +define+FPU+Single +access+r $(ARGS)

double: $(TB) $(SCMIPS)_FPU.v
	$(VLOG) $(TB) $(SCMIPS)_FPU.v $(DESIGNWARE) +define+FPU+Double +access+r $(ARGS)

fsyn: $(TB) $(SCMIPS)_FPU_syn.v $(TSMC)
	$(VLOG) $(TB) $(SCMIPS)_FPU_syn.v $(TSMC) +define+FPU+Single +access+r $(ARGS)
