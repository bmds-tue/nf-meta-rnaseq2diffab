
params.samplesheet = ""
params.conditions = ""
params.join_key = "sample"
params.outdir = ""


workflow rnaseq2diffab {

    main:

    samplesCh = channel
        .fromPath( params.samplesheet )
        .splitCsv( header: true )

    conditionsCh = channel
        .fromPath( params.conditions )
        .splitCsv( header: true )

    mergedCh = samplesCh
        .combine( conditionsCh )
        .filter  { s, c -> s[ params.join_key ] == c[ params.join_key ] }
        .map     { s, c -> s + c }
        .collect()
        .map { rows ->
            def outFile = file( "${params.outdir}/samplesheet.csv" )
            outFile.parent.mkdirs()
            outFile.text  = rows[0].keySet().join(',') + '\n'
            outFile.text += rows.collect { it.values().join(',') }.join('\n') + '\n'
            outFile
        }

    emit:
    merged_samplesheet = mergedCh

}

workflow {
    main:
    rnaseq2diffab()
    publish:
    merged_samplesheet = rnaseq2diffab.out.merged_samplesheet
}
