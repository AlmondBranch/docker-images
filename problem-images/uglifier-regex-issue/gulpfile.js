var gulp = require('gulp');
var uglify = require('gulp-uglify');
var pump = require('pump');

gulp.task('compress', function (cb) {
  pump([
        gulp.src('simple_regex.js'),
        uglify(),
        gulp.dest('uglifierOutput')
    ],
    cb
  );
});
