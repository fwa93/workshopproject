process PYCOQC {
    tag "$summary"
    label 'process_medium'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://community-cr-prod.seqera.io/docker/registry/v2/blobs/sha256/a4/a41bd36ec022b70789503469837325a5820a8777a54edcbdbce9d06c93e2bd98/data' :
        'biocontainers/pycoqc:2.5.2--py_0' }"

    input:
    path(summary)

    output:
    path    "*.html"                 , emit:html
    path    "*.json"                 , emit: json
    path    "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "pycoqc"
    """
    pycoQC \\
        $args \\
        -f $summary \\
        -o ${prefix}.html \\
        -j ${prefix}.json

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        pycoqc: \$(pycoQC --version 2>&1 | sed 's/^.*pycoQC v//; s/ .*\$//')
    END_VERSIONS
    """
}
