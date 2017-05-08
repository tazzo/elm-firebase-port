var gulp = require('gulp');
var elm = require('gulp-elm');
var gutil = require('gulp-util');
var plumber = require('gulp-plumber');
var connect = require('gulp-connect');

// File paths
var paths = {
  dest: 'public',
  elm: 'src/elm/**/*.elm',
  static: 'src/static/**/*.{html,css,jpg,png,js}',
  bower:'bower_components/**/*'
};

// Init Elm
gulp.task('elm-init', elm.init);

// Compile Elm
gulp.task('elm', ['elm-init'], function(){
    return gulp.src(paths.elm)
        .pipe(plumber())
        .pipe(elm())
        .pipe(gulp.dest(paths.dest));
});

// Move static assets to dist
gulp.task('static', function() {
    return gulp.src(paths.static)
        .pipe(plumber())
        .pipe(gulp.dest(paths.dest));
});

// Move bower assets to dist
gulp.task('bower', function() {
    return gulp.src(paths.bower)
        .pipe(plumber())
        .pipe(gulp.dest(paths.dest+'/bower_components'));
});

// Watch for changes and compile
gulp.task('watch', function() {
    gulp.watch(paths.elm, ['elm']);
    gulp.watch(paths.static, ['static']);
});

// Local server
gulp.task('connect', function() {
    connect.server({
        root: paths.dest,
        port: 3003
    });
});

// Main gulp tasks
gulp.task('build', ['elm', 'static','bower']);
gulp.task('default', [ 'build','connect', 'watch']);
