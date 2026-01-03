import "./style.css";
import { morphPatch } from "./morph_patch.js";
import "./main.dart";

globalThis.morphPatch = morphPatch;
