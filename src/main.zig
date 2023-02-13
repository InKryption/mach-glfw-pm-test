const std = @import("std");
const glfw = @import("mach-glfw");

pub fn main() !void {
    glfw.setErrorCallback(struct {
        fn glfwErrorCallback(error_code: glfw.ErrorCode, description: [:0]const u8) void {
            const mach_glfw_log = std.log.scoped(.@"mach-glfw");
            mach_glfw_log.err(
                \\
                \\Encountered error "{s}". Description:
                \\{s}
            , .{ @errorName(error_code), description });
        }
    }.glfwErrorCallback);
    defer glfw.setErrorCallback(null);

    if (!glfw.init(glfw.InitHints{})) return error.FailedToInitialiseGlfw;
    defer glfw.terminate();

    const window = glfw.Window.create(640, 640, "aufero-rl", null, null, glfw.Window.Hints{}) orelse return error.FailedToCreateWindow;
    defer window.destroy();

    window.setTitle("All working good, boss.");

    while (!window.shouldClose()) {
        glfw.pollEvents();
        window.swapBuffers();
    }
}
