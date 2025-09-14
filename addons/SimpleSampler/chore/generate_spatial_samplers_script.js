import fs from 'fs';
import path from 'path';

function generateSampler2DCode(sourceFrom) {
  return sourceFrom
    .replace(/Sampler/g, 'Sampler2D')
    .replace(/AudioStreamPlayer/g, 'AudioStreamPlayer2D');
}
function generateSampler3DCode(sourceFrom) {
  return sourceFrom
    .replace(/Sampler/g, 'Sampler3D')
    .replace(/AudioStreamPlayer/g, 'AudioStreamPlayer3D');
}

function generateSamplerInstrument2DCode(sourceFrom) {
  return sourceFrom.replace(/Sampler([^a-zA-Z0-9]|$)/g, "Sampler2D$1")
    .replace(/SamplerInstrument/g, "SamplerInstrument2D")
    .replace("## COPY_SAMPLER_2D: ", "")
}
function generateSamplerInstrument3DCode(sourceFrom) {
  return sourceFrom.replace(/Sampler([^a-zA-Z0-9]|$)/g, "Sampler3D$1")
    .replace(/SamplerInstrument/g, "SamplerInstrument3D")
    .replace("## COPY_SAMPLER_3D: ", "")
}

function generateScript(scriptFrom, fileName, transform) {
  const transformed = transform(scriptFrom);
  fs.writeFileSync(fileName, transformed, 'utf8');
}

/**
 * Generate the scripts for Sampler2D, Sampler3D, SamplerInstrument2D and SamplerInstrument3D
 * Since they have a identical behavior, but inherit a different class, this makes them easier to maintain.
 * This script should be run for every new version
 */
function main() {
  const addonsPath = path.resolve(path.dirname('.'), '..');
  console.log(`Generating spatial samplers in ${addonsPath}`);

  const samplerPath = path.join(addonsPath, 'sampler.gd');
  const samplerInstrumentPath = path.join(addonsPath, 'sampler_instrument.gd');

  const samplerScript = fs.readFileSync(samplerPath, 'utf8');
  const samplerInstrumentScript = fs.readFileSync(samplerInstrumentPath, 'utf8');

  generateScript(samplerScript, path.join(addonsPath, 'sampler_2D.gd'), generateSampler2DCode);
  generateScript(samplerScript, path.join(addonsPath, 'sampler_3D.gd'), generateSampler3DCode);

  generateScript(samplerInstrumentScript, path.join(addonsPath, 'sampler_instrument_2D.gd'), generateSamplerInstrument2DCode);
  generateScript(samplerInstrumentScript, path.join(addonsPath, 'sampler_instrument_3D.gd'), generateSamplerInstrument3DCode);

  console.log('Done.');
}

main();
