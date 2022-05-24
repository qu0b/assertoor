package task

import (
	"context"
	"time"

	"github.com/samcm/sync-test-coordinator/pkg/coordinator/clients/consensus"
	"github.com/sirupsen/logrus"
)

type ConsensusIsSyncingConfig struct {
}

type ConsensusIsSyncing struct {
	bundle *Bundle
	client *consensus.Client
	log    logrus.FieldLogger
	config ConsensusIsSyncingConfig
}

var _ Runnable = (*ConsensusIsSyncing)(nil)

const (
	NameConsensusIsSyncing = "consensus_is_syncing"
)

func NewConsensusIsSyncing(ctx context.Context, bundle *Bundle, config ConsensusIsSyncingConfig) *ConsensusIsSyncing {
	return &ConsensusIsSyncing{
		bundle: bundle,
		log:    bundle.log.WithField("task", NameConsensusIsSyncing),
		config: config,
	}
}

func DefaultConsensusIsSyncingConfig() ConsensusIsSyncingConfig {
	return ConsensusIsSyncingConfig{}
}

func (c *ConsensusIsSyncing) Name() string {
	return NameConsensusIsSyncing
}

func (c *ConsensusIsSyncing) Config() interface{} {
	return c.config
}

func (c *ConsensusIsSyncing) PollingInterval() time.Duration {
	return time.Second * 5
}

func (c *ConsensusIsSyncing) Start(ctx context.Context) error {
	c.client = c.bundle.GetConsensusClient(ctx)

	return nil
}

func (c *ConsensusIsSyncing) Logger() logrus.FieldLogger {
	return c.log
}

func (c *ConsensusIsSyncing) IsComplete(ctx context.Context) (bool, error) {
	status, err := c.client.GetSyncStatus(ctx)
	if err != nil {
		return false, err
	}

	return status.IsSyncing, err
}
