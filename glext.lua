f = io.open("glext.h","r")
print("#include \"GL/glext.h\"\n") 
for str in f:lines() do
  if str:match("#endif.+GL_VERSION_4_6") then break end
  local ret, name, param = str:match("GLAPI (.+)APIENTRY (%g+) ([^;]*)")
  if ret then
    local ptr = "PFN" .. name:upper() .. "PROC"
    local argname = {}
    for p in param:gmatch("([%w_]+)[,)%[]") do table.insert(argname, p) end
  --  local s = "inline " .. ret .. " " .. name .. " " .. param .. "{\n"
    local s = str:gsub("GLAPI", "inline"):gsub("APIENTRY ", ""):gsub(";", "{\n");
    s = s .. "  const static " .. ptr .. " glfunc = ((" .. ptr .. ")wglGetProcAddress(\"" .. name .. "\"));\n"
    s = s .. "  return glfunc ? glfunc("
    if argname[1] ~= "void" then s = s .. argname[1] end
    for i = 2, #argname do s = s .. ", " .. argname[i] end
    s = s .. ") : 0;\n}\n"
    print(s)
  end
end
f:close()