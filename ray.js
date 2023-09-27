CanvasRenderingContext2D.prototype.setStrokeColor = function (color) {
    const hexColor = "#" + color.toString(16).padStart(6, "0");
    this.strokeStyle = hexColor;
};

CanvasRenderingContext2D.prototype.setFillStyle = function (color) {
    const hexColor = "#" + color.toString(16).padStart(6, "0");
    this.fillStyle = hexColor;
};

// create a char buffer
const arr = []

const importObject = {
    canvas: {
        stroke_rect: (ctx, x, y, width, height) => ctx.strokeRect(x, y, width, height),
        stroke: (ctx) => ctx.stroke(),
        move_to: (ctx, x, y) => ctx.moveTo(x, y),
        line_to: (ctx, x, y) => ctx.lineTo(x, y),
        begin_path: (ctx) => ctx.beginPath(),
        fill_rect: (ctx, x, y, width, height) => ctx.fillRect(x, y, width, height),
        set_stroke_color: (ctx, color) => ctx.setStrokeColor(color),
        set_fill_style: (ctx, color) => ctx.setFillStyle(color),
    },
    math: {
        sqrt: (x) => Math.sqrt(x),
        log: (x) => Math.log(x),
        pow: (x, y) => Math.pow(x, y),
        trunc: (x) => Math.trunc(x),
        random: () => Math.random(),
        sin: (x) => Math.sin(x),
        cos: (x) => Math.cos(x),
        abs: (x) => Math.abs(x),
    },
    spectest: {
        print_i32: (x) => console.log(String(x)),
        print_f64: (x) => console.log(String(x)),
        print_char: (x) => console.log(String.fromCharCode(x)),
        log: console.log
    },
};

const canvas = document.getElementById("canvas");
canvas.width = 400;
canvas.height = 400;

if (canvas.getContext) {
    const ctx = canvas.getContext("2d");

    await WebAssembly.instantiateStreaming(fetch("target/smallpt.wasm"), importObject).then(
        (obj) => {
            obj.instance.exports._start();
            console.log(obj.instance.exports)
            const render = obj.instance.exports["smallpt/main::render"];
            const online = obj.instance.exports["smallpt/main::online"];
            const run = obj.instance.exports["smallpt/main::run"];
            online(ctx)
        }
    )
}
