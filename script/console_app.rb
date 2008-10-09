# work around the at_exit hook in test/unit, which kills IRB
Test::Unit.run = true if Test::Unit.respond_to?(:run=)
