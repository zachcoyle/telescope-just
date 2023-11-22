local has_telescope, telescope = pcall(require, "telescope")
if not has_telescope then
  error("telescope not available")
end
