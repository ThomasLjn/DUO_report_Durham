//-------------------------------------
// Document options
//
#let option = (
  type : "final",
  //type : "draft",
  lang : "en",
  //lang : "de",
  //lang : "fr",
)
//-------------------------------------
// Optional generate titlepage image
//
#import "@preview/fractusist:0.1.1":*  // only for the generated images

#let titlepage_logo= dragon-curve(
  12,
  step-size: 10,
  stroke-style: stroke(
    //paint: gradient.linear(..color.map.rocket, angle: 135deg),
    paint: gradient.radial(..color.map.rocket),
    thickness: 3pt, join: "round"),
  height: 10cm,
)

//-------------------------------------
// Metadata of the document
//
#let doc= (
  title    : [*Report on DUO calculations*],
  abbr     : none,
  subtitle : [_Methods and results_],
  // url      : "https://synd.hevs.io",
  logos: (
    tp_topleft  : image("resources/img/logo_ens.png", height: 1.2cm),
    tp_topright : image("resources/img/durham_univ_logo.png", height: 1.5cm),
    tp_main     : titlepage_logo,
    // header      : image("resources/img/project-logo.svg", width: 2.5cm),
  ),
  authors: (
    (
      name        : "Thomas Lejeune",
      abbr        : "T.L",
      email       : "thomas.lejeune@ens-paris-saclay.fr",
      // url         : "https://synd.hevs.io",
    ),
  ),
  school: (
    name        : "Durham University",
    major       : "Physics",
    orientation : none,
    url         : "https://www.cornishlabs.uk/",
  ),

  keywords : ("Typst", "Template", "Report", "HEI-Vs", "Systems Engineering", "Infotronics"),
  version  : "v0.1.0",
)

#let date= datetime.today()

//-------------------------------------
// Settings
//
#let tableof = (
  toc: false,
  tof: false,
  tot: false,
  tol: false,
  toe: false,
  maxdepth: 3,
)

#let gloss    = false
#let appendix = false
#let bib = (
  display : true,
  path  : "/tail/bibliography.bib",
  style : "nature", //"apa", "chicago-author-date", "chicago-notes", "mla"
)
