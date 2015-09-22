#!/usr/bin/env cwl-runner

class: Workflow
requirements:
  - import: ../../engines/node-engine.cwl
  - import: ../../tools/envvar-global.cwl
  - import: ../../tools/bedtools-genomecov-types.cwl

inputs:
  - id: "#type"
    type: string
  - id: "#scale"
    type: float
  - id: "#input"
    type: File
    inputBinding:
      secondaryFiles:
        - engine: ../../engines/node-engine.cwl
          script: |
           {
            if ((/.*\.bam$/i).test($job['input'].path))
               return {"path": $job['input'].path+".bai", "class": "File"};
            return [];
           }
  - id: "#genomeFile"
    type: File

outputs:
  - id: "#outfile"
    type: File
    #source: "#bigwig.fileout"
    source: "#sort.sorted"

steps:
  - id: "#genomecov"
    run: {import: ../../tools/bedtools-genomecov.cwl}
    inputs:
      - {id: "#genomecov.input", source: "#input"}
      - {id: "#genomecov.genomeFile", source: "#genomeFile"}
      - {id: "#genomecov.genomecoverageout", default: "genomecov.bed" }
      - {id: "#genomecov.dept", type: '../../tools/bedtools-genomecov-types.cwl#depts' , default: {'dept': '-bg' } }
      - {id: "#genomecov.scale", source: "#scale" }
    outputs:
      - {id: "#genomecov.genomecoverage"}

  - id: "#sort"
    inputs:
      - {id: "#sort.sortinput", source: "#genomecov.genomecoverage"}
    outputs:
      - {id: "#sort.sorted"}
    run:
      class: CommandLineTool
      inputs:
        - id: "#sortinput"
          type: File
          inputBinding:
            position: 1
      outputs:
        - id: "#sorted"
          type: File
          description: "The sorted file"
          outputBinding:
            glob: "sorted.bed"
      stdout: "sorted.bed"
      baseCommand: "sort"
      arguments: [ "-k1,1", "-k2,2n" ]
