import "./style.css";
import { morphPatch } from "../vendor/morph_patch.js";
import "./main.dart";

globalThis.morphPatch = morphPatch;
