local PeripheralRouter = require('../generics/peripheral_router')

-- Wrap the monitor
local monitor = peripheral.wrap(PeripheralRouter.findPeripheralSide('monitor'))

-- Write Hello World! to the monitor
monitor.clear()
monitor.setCursorPos(1, 1)
monitor.write('Hello World!')
