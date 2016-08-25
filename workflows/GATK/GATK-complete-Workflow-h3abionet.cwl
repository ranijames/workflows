#!/usr/bin/env cwl-runner

class: Workflow
cwlVersion: v1.0

inputs:
  reference:
    type: File
    doc: reference human genome file

  reads:
    type: File[]?
    doc: files containing the paired end reads in fastq format required for bwa-mem

  bwa_output_name:
    type: string
    doc: name of bwa-mem output file

  output_RefDictionaryFile:
    type: string
    doc: output file name for picard create dictionary command from picard toolkit

  samtools-view-isbam:
    type: boolean
    doc: boolean set to output bam file from samtools view

  samtools-index-bai:
    type: boolean
    doc: boolean set to output bam file from samtools view

  output_samtools-view:
    type: string
    doc: output file name for bam file generated by samtools view

  output_samtools-sort:
    type: string
    doc: output file name for bam file generated by samtools sort

  outputFileName_MarkDuplicates:
    type: string
    doc: output file name generated as a result of Markduplicates command from picard toolkit

  metricsFile_MarkDuplicates:
    type: string
    doc: metric file generated by MarkDupicates command listing duplicates

  readSorted_MarkDuplicates:
    type: string
    doc: set to be true showing that reads are sorted already

  removeDuplicates_MarkDuplicates:
    type: string
    doc: set to be true

  createIndex_MarkDuplicates:
    type: string
    doc: set to be true to create .bai file from Picard Mark Duplicates

  outputFileName_RealignTargetCreator:
    type: string
    doc: name of realignTargetCreator output file

  known_variant_db:
    type: File[]?
    doc: array of known variant files for realign target creator

  outputFileName_IndelRealigner:
    type: string
    doc: name of indelRealigner output file

  outputFileName_BaseRecalibrator:
    type: string
    doc: name of BaseRecalibrator output file

  outputFileName_PrintReads:
    type: string
    doc: name of PrintReads command output file

  outputFileName_HaplotypeCaller:
    type: string
    doc: name of Haplotype caller command output file

  dbsnp:
    type: File
    doc: vcf file containing SNP variations used for Haplotype caller

  tmpdir:
    type: string?
    doc: temporary dir for picard

  samtools-view-sambam:
    type: string?
    doc: temporary dir for picard

  covariate:
    type: string[]?
    doc: required for base recalibrator

outputs:
  bwamem_output:
    type: File
    outputSource: bwa-mem/output

  ReferenceSequenceDictionary:
    type: File
    outputSource: create-dict/output

  samtoolsView_output:
    type: File
    outputSource: samtools-view/output

  samtoolsSort_output:
    type: File
    outputSource: samtools-sort/sorted

  samtoolsIndex_output:
    type: File
    outputSource: samtools-index/index

  MarkDuplicates_output:
    type: File
    outputSource: MarkDuplicates/markDups_output
#
#  output_realignTarget:
#    type: File
#    outputSource: RealignTarget/output_realignTarget
#
#  output_indelRealigner:
#    type: File
#    outputSource: IndelRealigner/output_indelRealigner
#
#  outputfile_baseRecalibrator:
#    type: File
#    outputSource: BaseRecalibrator/output_baseRecalibrator
#
#  output_printReads:
#    type: File
#    outputSource: PrintReads/output_PrintReads
#
#  output_HaplotypeCaller:
#    type: File
#    outputSource: HaplotypeCaller/output_HaplotypeCaller
#
steps:

  create-dict:
    run: ../../tools/picard-CreateSequenceDictionary.cwl  # FIXME: this is draft3
    in:
      reference: reference
      output_filename: output_RefDictionaryFile
    out: [ output ]

  bwa-mem:
    run: ../../tools/bwa-mem.cwl
    in:
      reference: reference
      reads: reads
      dictCreated: create-dict/output
      output_filename: bwa_output_name
    out: [ output ]

  samtools-view:
    run: ../../tools/samtools-view.cwl
    in:
      input: bwa-mem/output
      isbam: samtools-view-isbam
      sambam: samtools-view-sambam
      output_name: output_samtools-view
    out: [ output ]

  samtools-sort:
    run: ../../tools/samtools-sort.cwl
    in:
      input: samtools-view/output
      output_name: output_samtools-sort
    out: [ sorted ]

  samtools-index:
    run: ../../tools/samtools-index.cwl
    in:
      input: samtools-sort/sorted
      bai: samtools-index-bai
    out: [ index ]

  MarkDuplicates:
    run: ../../tools/picard-MarkDuplicates.cwl
    in:
      outputFileName_markDups: outputFileName_MarkDuplicates
      inputFileName_markDups:
        source: samtools-sort/sorted
        valueFrom: ${return [ self ];}
      metricsFile: metricsFile_MarkDuplicates
      readSorted: readSorted_MarkDuplicates
      removeDuplicates: removeDuplicates_MarkDuplicates
      createIndex: createIndex_MarkDuplicates
    out: [ markDups_output ]

#  RealignTarget:
#    run: ../../tools/GATK-RealignTargetCreator.cwl # FIXME: this is draft 3
#    in:
#      outputfile_realignTarget: outputFileName_RealignTargetCreator
#      inputBam_realign: MarkDuplicates/markDups_output
#      reference: reference
#      known: known_variant_db
#    out: [ output_realignTarget ]
#
#  IndelRealigner:
#    run: ../../tools/GATK-IndelRealigner.cwl  # FIXME: this is draft 3
#    in:
#      outputfile_indelRealigner: outputFileName_IndelRealigner
#      inputBam_realign: MarkDuplicates/markDups_output
#      intervals: RealignTarget/output_realignTarget
#      reference: reference
#      known: known_variant_db
#    out: [ output_indelRealigner ]
#
#  BaseRecalibrator:
#    run: ../../tools/GATK-BaseRecalibrator.cwl  # FIXME: this is draft 3
#    in:
#      outputfile_BaseRecalibrator: outputFileName_BaseRecalibrator
#      inputBam_BaseRecalibrator: IndelRealigner/output_indelRealigner
#      reference: reference
#      covariate: covariate
#      known: known_variant_db
#    out: [ output_baseRecalibrator ]
#
#  PrintReads:
#    run: ../../tools/GATK-PrintReads.cwl  # FIXME: this is draft 3
#    in:
#      outputfile_printReads: outputFileName_PrintReads
#      inputBam_printReads: IndelRealigner/output_indelRealigner
#      reference: reference
#      input_baseRecalibrator: BaseRecalibrator/output_baseRecalibrator
#    out: [ output_PrintReads ]
#
#  HaplotypeCaller:
#    run: ../../tools/GATK-HaplotypeCaller.cwl  # FIXME: this is draft 3
#    in:
#      outputfile_HaplotypeCaller: outputFileName_HaplotypeCaller
#      inputBam_HaplotypeCaller: PrintReads/output_PrintReads
#      reference: reference
#      dbsnp: dbsnp
#    out: [ output_HaplotypeCaller ]
