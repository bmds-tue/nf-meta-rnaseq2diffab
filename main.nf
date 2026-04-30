
params {
    samplesheet: Path
    conditions: Path
    join_key: String
    outdir: String
}

workflow rnaseq2diffab {

    main:

    def samplesCh = channel
        .fromPath( params.samplesheet )
        .splitCsv( header: true )

    def conditionsCh = channel
        .fromPath( params.conditions )
        .splitCsv( header: true )

    def mergedCh = samplesCh
        .combine( conditionsCh )
        .filter  { s, c -> s[ params.join_key ] == c[ params.join_key ] }
        .map     { s, c -> s + c }
        .collect()
        .map { rows ->
            def outFile = file( "${params.outdir}/merged_samplesheet.csv" )
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

output {
    merged_samplesheet: Channel<Path> {
        path "${params.outdir}/samplesheet_with_conditions.csv"
    }
}
