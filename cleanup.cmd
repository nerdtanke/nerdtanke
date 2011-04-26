@echo off
forfiles /s /m *~ -c "cmd /c echo @path && del @path"
